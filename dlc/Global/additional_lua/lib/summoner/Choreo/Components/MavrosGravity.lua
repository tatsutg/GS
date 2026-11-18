------
-- summoner.Choreo.Components.MavrosGravity
--
-- マヴロスギア種の共有ギミック「時空追放（重力吸引）」: spine イベント連鎖で対象1体を拘束し、
-- 画面外へ退場させ、拘束が切れたら上空から復帰させる。
--   gravityStart（対象決定・拘束付与）→ hideUnit → gravityEnd（退場メッセージ）→ update で維持 → 復帰
-- 拘束は 気絶(89) ＋ 判別用フラグ(0) ＋ スキルCT(29) ＋ 装備CT(30) の4点セットで、
-- スキル/装備のクールタイムも実際にリセットする（＝復帰後もすぐには動けない）。
-- 出典: enemy/2004542.lua（樹木マヴロスギア）の gravityStart/gravityEnd/hideUnit/glabControll/
--   useHold/useFinish/addStanBuff/itemCtReset/receive5 一式。2054701 も同構成。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: アニメに runScript-gravityStart / hideUnit / gravityEnd
--    （マヴロスギア spine 500155513 は attack5 に有り）。
-- ⚠ 対象の決定はホストが行い、Sync チャンネルで全端末へ配信する（原作の receive5 相当）。
--
-- 設定:
--   duration  number  拘束の持続秒数（既定 40）
--   ids       table    condition ID の上書き { stun=, flag=, skillCT=, itemCT=, debuff= }
--                      （既定は種共通の 500151 / 500152 / 500153 / 500154 と、復帰デバフ用 -50015）
--                      ⚠ debuff は flag と必ず別IDにする（同じにすると復帰処理が毎フレーム再実行される）
--   holdY     number  拘束中に対象を退避させるY座標（既定 -1000＝画面外）
--   dropY     number  復帰時に対象を落とす高さ（既定 1000）
--   message   string  退場時のメッセージ（既定 "が時空の狭間に消えた……" を対象名の後ろに付ける。false で無効）
--   releaseDebuffs table  復帰時に対象へ付与するデバフ列 {{type=,value=,time=,icon=}, ...}
--                        （既定は原作の 攻撃力-50%/10秒 と 攻撃速度-20%/10秒。{} で無効）
--   onCapture Action|list  拘束時のアクション（event.capturedUnit に対象）
--   onRelease Action|list  復帰時のアクション（event.capturedUnit に対象）
--
-- @example
--     boss:add(MavrosGravity{ duration = 40 })
--     boss:add(MavrosGravity{ duration = 10, releaseDebuffs = {} })
------
local _NAME = 'summoner.Choreo.Components.MavrosGravity'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')
local Color = require('summoner.Color')

-- 復帰時デバフ（原作 2004542 の BUFF_BOX_LIST[4][5] 相当）。
-- ID は互いに別にする: 同IDだと後から付けた方が上書きして片方が効かない。
local DEFAULT_RELEASE_DEBUFFS = {
    { id = -50015, type = 13, value = -50, time = 10, icon = 4 },   -- 攻撃力ダウン
    { id = -50016, type = 28, value = -20, time = 10, icon = 8 },   -- 攻撃速度ダウン
}

local function battle()
    return megast.Battle:getInstance()
end

-- スキル・装備のクールタイムを全リセット（原作 resetSkillCoolTime + itemCtReset）
local function resetCoolTimes(unit)
    unit:resetSkillCoolTime()
    for n = 0, 2 do
        local item = unit:getItemSkill(n)
        if item ~= nil then
            item:resetCooltime()
        end
    end
end

local function MavrosGravity(config)
    config = config or {}
    local duration = config.duration or 40
    local ids = config.ids or {}
    local stunID = ids.stun or 500151
    local flagID = ids.flag or 500152
    local skillCTID = ids.skillCT or 500153
    local itemCTID = ids.itemCT or 500154
    -- 復帰デバフのID。判別フラグと別IDでなければ「まだ拘束中」と誤判定して復帰処理を繰り返す（原作は -50015）
    local debuffID = ids.debuff or -50015
    local holdY = config.holdY or -1000
    local dropY = config.dropY or 1000
    local releaseDebuffs = config.releaseDebuffs or DEFAULT_RELEASE_DEBUFFS

    local component = { name = 'MavrosGravity' }

    local function onLoad(self, event)
        self._mavGravTarget = nil
        self._mavGravActive = false
    end

    -- 拘束: 気絶＋フラグ＋スキルCT＋装備CT を付与し、CT を実リセット
    local function bind(self, target)
        local cond = target:getTeamUnitCondition()
        cond:addCondition(stunID, 89, 100, duration, 0)
        cond:addCondition(flagID, 0, 0, 99999, 0)
        cond:addCondition(skillCTID, 29, -1000, duration, 0)
        cond:addCondition(itemCTID, 30, -1000, duration, 0)
        resetCoolTimes(target)
    end

    -- 復帰: フラグ除去 → 上空から落として復帰 → デバフ付与 → CT 再リセット
    local function release(self, event, target)
        local cond = target:getTeamUnitCondition()
        local flag = cond:findConditionWithID(flagID)
        if flag ~= nil then
            cond:removeCondition(flag)
        end
        target:getSkeleton():setPosition(0, dropY)
        target:setOpacity(255)
        target:resumeUnit()
        if target:getBurstPoint() < 0 then
            target:setBurstPoint(0)
        end
        for i = 1, #releaseDebuffs do
            local d = releaseDebuffs[i]
            cond:addCondition(d.id or debuffID, d.type, d.value, d.time or 10, d.icon or 0)
        end
        resetCoolTimes(target)
        if self._mavGravTarget == target then
            self._mavGravTarget = nil
        end
        event.capturedUnit = target
        Action.runActions(self, event, config.onRelease)
    end

    local function onRun(self, event)
        local ev = event.spineEvent
        if ev == 'gravityStart' then
            if not self.isHostPlayer then
                return
            end
            local target = event.unit:getTargetUnit()
            if target ~= nil then
                self:hostDecide('mavrosGravityPick', target:getIndex())
            end
        elseif ev == 'gravityEnd' then
            local target = self._mavGravTarget
            if target == nil then
                return
            end
            bind(self, target)          -- 原作どおり拘束を上書き（退場中の解除ずれ防止）
            if config.message ~= false then
                local text = (self.TEXT ~= nil and self.TEXT.GRAVITY_MESSAGE1)
                    or config.message or "が時空の狭間に消えた……"
                summoner.Utility.messageByEnemy(target:getUnitName() .. text, 7, Color.red)
            end
            event.unit:setInvincibleTime(0)
            self._mavGravActive = false
        end
    end

    -- 拘束の維持と解除判定（原作 glabControll）
    local function onUpdate(self, event)
        local team = battle():getTeam(true)
        for i = 0, 6 do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                local cond = u:getTeamUnitCondition()
                if cond:findConditionWithID(flagID) ~= nil then
                    if cond:findConditionWithID(stunID) ~= nil then
                        u:setPosition(u:getPositionX(), holdY)   -- 画面外で維持
                    else
                        release(self, event, u)                  -- 気絶が切れた＝復帰
                    end
                end
            end
        end
    end

    function component.initialize(dispatcher)
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel('mavrosGravityPick', function(self, index)
            local target = battle():getTeam(true):getTeamUnit(index)
            if target == nil then
                return
            end
            self._mavGravTarget = target
            self._mavGravActive = true
            target:resumeUnit()
            bind(self, target)
            local e = { unit = self.unit, capturedUnit = target }
            Action.runActions(self, e, config.onCapture)
        end)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = MavrosGravity
return MavrosGravity
