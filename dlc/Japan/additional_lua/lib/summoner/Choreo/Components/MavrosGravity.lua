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
--   duration  number  拘束の持続秒数（既定 40）。0 / false で無期限（解除は releaseOn と対象の死亡のみ）
--   target    Targeting  対象の決め方（既定 nil＝ボスの現在のターゲット。'hate' で累計ダメージ最大。
--                     hate は HateTarget Component と併用。HateTarget にアイコンもバフも無い（engine の
--                     ヘイト対象が無い）ときは、HateTarget の累計から最大の生存ユニットを取る。原作 2004542 の selectTarget）
--   resetCT   bool    拘束・復帰時にスキル/装備のクールタイムを止めてリセットする（既定 true＝原作）
--   ids       table    condition ID の上書き { stun=, flag=, skillCT=, itemCT=, debuff=, dot= }
--                      （既定は種共通の 500151 / 500152 / 500153 / 500154 と、復帰デバフ用 -50015、継続ダメージ用 500155）
--                      ⚠ debuff は flag と必ず別IDにする（同じにすると復帰処理が毎フレーム再実行される）
--   holdY     number  拘束中に対象を退避させるY座標（既定 -1000＝画面外）
--   dropY     number  復帰時に対象を落とす高さ（既定 1000）
--   message   string  退場時のメッセージ（既定 "が時空の狭間に消えた……" を対象名の後ろに付ける。false で無効）
--   messageColor Color 退場メッセージの色（既定 赤）
--   releaseDebuffs table  復帰時に対象へ付与するデバフ列 {{type=,value=,time=,icon=}, ...}
--                        （既定は原作の 攻撃力-50%/10秒 と 攻撃速度-20%/10秒。{} で無効）
--   dot       number|table  拘束中の継続ダメージ（秒間。condition type 129＝エンジンの DoT 処理。HP は1で止まる）。
--                           動的値可（{ base = 0, perFloor = 5 } で 秒間[階層×5]）。プレイヤーが受ける DoT は
--                           condition の値×CONF_DoT_OFFSET_EvP（0.1）なので、condition には秒間ダメージ÷0.1 を付ける
--   keepInvincible bool  gravityEnd でボスの無敵を解除しない（既定 false＝原作どおり解除する）。
--                     HP トリガーの奥義で出して「撃ち終わりまで無敵」にするときは true にし、
--                     SkillFinishWatch の onFinish で Invincible{ 0 } する
--   zeroSP    bool    拘束中は対象の奥義ゲージを0に固定する
--   releaseOn table   ボスがこの状態になったら拘束を解く { 'stun'（ボスが気絶）, 'break'（ボスがブレイク） }
--   bossDebuffs table 拘束中だけボスに付ける condition 列 {{id=,type=,value=,icon=}, ...}（解除で外す）。
--                     例: 気絶耐性200%ダウン = {{ type = 101, value = -200 }, { type = 52, value = -200 }}
--   captureMessages table  退場メッセージの後に出すメッセージ列 {{ text=, color=, time=, name=true }, ...}
--                          name=true で text の前に対象名を付ける
--   releaseMessages table  releaseOn で拘束を解いたときに出すメッセージ列（書式は captureMessages と同じ）
--   onCapture Action|list  拘束時のアクション（event.capturedUnit に対象）
--   onRelease Action|list  復帰時のアクション（event.capturedUnit に対象。対象の死亡で終わったときは nil）
--
-- @example
--     boss:add(MavrosGravity{ duration = 40 })
--     boss:add(MavrosGravity{ duration = 10, releaseDebuffs = {} })
--     -- 鉱山マヴロギアス: 累計ダメージ最大を60秒拘束、ボスの気絶・ブレイクで解除。
--     -- HP トリガーの奥義（UseSkill{ invincible }）で出し、撃ち終わりまで無敵を残す
--     boss:add(MavrosGravity{ duration = 60, target = Targeting{ pick = 'hate' }, resetCT = false,
--         releaseDebuffs = {}, dot = { base = 0, perFloor = 5 }, zeroSP = true, keepInvincible = true,
--         releaseOn = { 'stun', 'break' },
--         bossDebuffs = {{ type = 101, value = -200 }, { type = 52, value = -200 }} })
------
local _NAME = 'summoner.Choreo.Components.MavrosGravity'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Actions = require('summoner.Choreo.Actions')
local Sync = require('summoner.Choreo.Components.Sync')
local Color = require('summoner.Color')

-- 復帰時デバフ（原作 2004542 の BUFF_BOX_LIST[4][5] 相当）。
-- ID は互いに別にする: 同IDだと後から付けた方が上書きして片方が効かない。
local DEFAULT_RELEASE_DEBUFFS = {
    { id = -50015, type = 13, value = -50, time = 10, icon = 4 },   -- 攻撃力ダウン
    { id = -50016, type = 28, value = -20, time = 10, icon = 8 },   -- 攻撃速度ダウン
}

local INDEFINITE = 99999
local BOSS_DEBUFF_ID = 500160   -- bossDebuffs の既定ID（i 番目は +i-1）
local PLAYER_DOT_RATE = 0.1     -- プレイヤーが受ける DoT の倍率（設定マスター CONF_DoT_OFFSET_EvP。Team::DoTCheck）
local MAX_INDEX = 7             -- チーム枠 0..7（HateTarget と同じ）

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

local function removeByID(cond, id)
    local c = cond:findConditionWithID(id)
    local guard = 0
    while c ~= nil and guard < 10 do
        cond:removeCondition(c)
        c = cond:findConditionWithID(id)
        guard = guard + 1
    end
end

-- 色は Color の値か色名（'white' 等）。yaml の messageColor は色名のまま渡ってくる
local function toColor(c, default)
    if type(c) == 'string' then
        return Color[c] or default
    end
    return c or default
end

local function showMessages(list, target)
    if list == nil then
        return
    end
    for i = 1, #list do
        local m = list[i]
        local text = m.text or m[1] or ''
        if m.name and target ~= nil then
            text = target:getUnitName() .. text
        end
        summoner.Utility.messageByEnemy(text, m.time or 7, toColor(m.color, Color.yellow))
    end
end

local function MavrosGravity(config)
    config = config or {}
    local duration = config.duration
    if duration == nil then
        duration = 40
    elseif duration == false or duration == 0 then
        duration = INDEFINITE
    end
    local resetCT = config.resetCT ~= false
    local keepInvincible = config.keepInvincible == true
    local ids = config.ids or {}
    local stunID = ids.stun or 500151
    local flagID = ids.flag or 500152
    local skillCTID = ids.skillCT or 500153
    local itemCTID = ids.itemCT or 500154
    -- 復帰デバフのID。判別フラグと別IDでなければ「まだ拘束中」と誤判定して復帰処理を繰り返す（原作は -50015）
    local debuffID = ids.debuff or -50015
    local dotID = ids.dot or 500155
    local holdY = config.holdY or -1000
    local dropY = config.dropY or 1000
    local releaseDebuffs = config.releaseDebuffs or DEFAULT_RELEASE_DEBUFFS
    local messageColor = toColor(config.messageColor, Color.red)
    local bossDebuffs = config.bossDebuffs or {}
    local releaseOnStun, releaseOnBreak = false, false
    for _, r in ipairs(config.releaseOn or {}) do
        if r == 'stun' then releaseOnStun = true end
        if r == 'break' then releaseOnBreak = true end
    end

    local component = { name = 'MavrosGravity' }

    local function onLoad(self, event)
        self._mavGravTarget = nil
        self._mavGravIndex = nil
        self._mavGravActive = false
        self._mavGravDot = nil
    end

    -- 拘束: 気絶＋フラグ（＋スキルCT・装備CT＋CT リセット）（＋継続ダメージ）を付与
    local function bind(self, target)
        local cond = target:getTeamUnitCondition()
        cond:addCondition(stunID, 89, 100, duration, 0)
        cond:addCondition(flagID, 0, 0, INDEFINITE, 0)
        if resetCT then
            cond:addCondition(skillCTID, 29, -1000, duration, 0)
            cond:addCondition(itemCTID, 30, -1000, duration, 0)
            resetCoolTimes(target)
        end
        if self._mavGravDot ~= nil and self._mavGravDot > 0 then
            cond:addCondition(dotID, 129, self._mavGravDot / PLAYER_DOT_RATE, duration, 0)
        end
        if config.zeroSP then
            target:setBurstPoint(0)
        end
    end

    -- ボス側の後始末（拘束中だけのデバフを外す）。復帰でも対象の死亡でも呼ぶ
    local function clearBoss(self)
        if #bossDebuffs == 0 then
            return
        end
        local cond = self.unit:getTeamUnitCondition()
        for i = 1, #bossDebuffs do
            removeByID(cond, bossDebuffs[i].id or (BOSS_DEBUFF_ID + i - 1))
        end
        battle():updateConditionView()
    end

    -- 復帰: フラグ除去 → 上空から落として復帰 → デバフ付与 → CT 再リセット
    local function release(self, event, target)
        local cond = target:getTeamUnitCondition()
        local flag = cond:findConditionWithID(flagID)
        if flag ~= nil then
            cond:removeCondition(flag)
        end
        removeByID(cond, dotID)
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
        if resetCT then
            resetCoolTimes(target)
        end
        if self._mavGravTarget == target or self._mavGravIndex == target:getIndex() then
            self._mavGravTarget = nil
            self._mavGravIndex = nil
            clearBoss(self)
        end
        event.capturedUnit = target
        Action.runActions(self, event, config.onRelease)
    end

    -- HateTarget の累計（_hateTotals）が最大の生存ユニット（同値は index の小さい方。HateTarget の topIndex と同じ）
    local function topDamageUnit(self)
        local totals = self._hateTotals
        if totals == nil then
            return nil
        end
        local team = battle():getTeam(true)
        local best, bestValue = nil, 0
        for i = 0, MAX_INDEX do
            local v = totals[i]
            if v ~= nil and v > bestValue then
                local u = team:getTeamUnit(i)
                if u ~= nil then
                    best, bestValue = u, v
                end
            end
        end
        return best
    end

    local function onRun(self, event)
        local ev = event.spineEvent
        if ev == 'gravityStart' then
            if not self.isHostPlayer then
                return
            end
            local target
            if config.target ~= nil then
                target = config.target:resolve(self, event)
                if target == nil and config.target.pick == 'hate' then
                    target = topDamageUnit(self)     -- フォーカス表示の無い HateTarget でも累計最大を取る
                end
            end
            if target == nil then
                target = event.unit:getTargetUnit()
            end
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
                summoner.Utility.messageByEnemy(target:getUnitName() .. text, 7, messageColor)
            end
            showMessages(config.captureMessages, target)
            if not keepInvincible then
                event.unit:setInvincibleTime(0)
            end
            self._mavGravActive = false
        end
    end

    -- ボスが気絶・ブレイクしたら拘束を解く（気絶を外す → 次の判定で復帰）。
    -- 全端末で判定する（状態異常・ブレイクは engine が同期するので、各端末が同じ結果になる。OnStatus と同じ設計）
    local function checkReleaseOn(self)
        if self._mavGravIndex == nil or self._mavGravActive then
            return false   -- 退場演出中（gravityEnd 前）は判定しない
        end
        local unit = self.unit
        local hit = (releaseOnBreak and unit:isBreak())
            or (releaseOnStun and unit:getTeamUnitCondition():findConditionWithType(89) ~= nil)
        if not hit then
            return false
        end
        local target = battle():getTeam(true):getTeamUnit(self._mavGravIndex)
        if target ~= nil then
            removeByID(target:getTeamUnitCondition(), stunID)
        end
        return true
    end

    -- 拘束の維持と解除判定（原作 glabControll）
    local function onUpdate(self, event)
        local freed = checkReleaseOn(self)
        local team = battle():getTeam(true)
        -- 対象の死亡: 戦闘不能の枠は getTeamUnit が nil を返す。ボス側だけ後始末する
        if self._mavGravIndex ~= nil and not self._mavGravActive and team:getTeamUnit(self._mavGravIndex) == nil then
            self._mavGravTarget = nil
            self._mavGravIndex = nil
            clearBoss(self)
            event.capturedUnit = nil
            Action.runActions(self, event, config.onRelease)
            return
        end
        for i = 0, 6 do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                local cond = u:getTeamUnitCondition()
                if cond:findConditionWithID(flagID) ~= nil then
                    if cond:findConditionWithID(stunID) ~= nil then
                        u:setPosition(u:getPositionX(), holdY)   -- 画面外で維持
                        if config.zeroSP then
                            u:setBurstPoint(0)
                        end
                    else
                        release(self, event, u)                  -- 気絶が切れた＝復帰
                        if freed then
                            showMessages(config.releaseMessages, u)
                        end
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
            self._mavGravIndex = index
            self._mavGravActive = true
            if config.dot ~= nil then
                self._mavGravDot = Actions.resolveValue(config.dot, self, {})
            end
            target:resumeUnit()
            bind(self, target)
            if #bossDebuffs > 0 then
                local cond = self.unit:getTeamUnitCondition()
                for i = 1, #bossDebuffs do
                    local b = bossDebuffs[i]
                    cond:addCondition(b.id or (BOSS_DEBUFF_ID + i - 1), b.type, b.value, INDEFINITE, b.icon or 0)
                end
                battle():updateConditionView()
            end
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
