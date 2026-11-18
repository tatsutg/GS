------
-- summoner.Choreo.Components.OrdeusDeathScene
--
-- オルデウス種の共有ギミック「滅魂宿世」: 奥義演出に連動した
-- 「全停止(generalPause)→対象選出(target)→暗転→掴み(fadeInTarget)→Hit(death)→復帰」のシーケンス。
-- Hit 時の効果（固定ダメ/割合ダメ/デバフ/即死…）は個体ごとに不定なため onHit スロットに外出しする。
-- 出典: enemy/4002402.lua（超新星級オルデウス・絶）/ gb_602601.lua。調査は claudeDatas/ORDEUS_KIND_AGENT.md。
--
-- ⚠ update（フェード処理）を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: 奥義アニメに runScript-generalPause/target/fadeInTarget/specialUpdate/death。
--    death だけの個体（遺跡/鉱山型）は cinematic=false で演出系イベントを購読しない。
-- ⚠ 対象選出（pick="cursed"）はホスト決定→Sync チャンネルで全端末同期（原作の receive10 相当）。
-- ⚠ gb 版の霧モード（addOrbitSystemCamera の blackmist）は未対応。必要になったら別 Component にする。
-- ⚠ 原作 4002402 の fadeOutAll/fadeInAll は consts へ書く typo でフェードが実質無効。本実装は
--    フラグを self に持つ正実装（gb 系の意図した挙動）。
--
-- 設定:
--   cinematic  bool    フル演出（generalPause〜復帰）を使うか（既定 true。false=death のみ購読）
--   pick       string  "none"=対象ピックなし（全体攻撃型・既定） / "cursed"=呪い状態から1体ランダム
--   grabOrbit  string  掴み演出で対象位置に出すオービットアニメ（既定 "skill3player"）
--   onHit      Action|list  Hit（death イベント）時の効果。実行時 event に以下を積む:
--                 event.castCount   この奥義の発動回数（1始まり）
--                 event.pickedUnit  選出対象（pick="cursed" 時。なければ nil）
--                 event.cursedUnits 呪い(95)状態の味方側ユニット配列
--
-- @example
--     boss:add(OrdeusDeathScene{ cinematic = true, pick = "none", onHit = {
--         FixedDamage{ amount = 5000, side = "player" },
--         function(self, e) --[[ e.castCount / e.cursedUnits で個体差効果 ]] end,
--     } })
------
local _NAME = 'summoner.Choreo.Components.OrdeusDeathScene'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')

local ONE_FRAME = 0.016666667
local UNIT_HEIGHT = 100        -- 掴み演出の対象頭上オフセット（原作 consts.unitHight）
local STUN_ID = 9990           -- 演出用の一時コンディション ID（原作 09990）

local function battle()
    return megast.Battle:getInstance()
end

-- 味方側（プレイヤーチーム）で呪い(95)状態のユニットを集める
local function collectCursed()
    local list = {}
    local team = battle():getTeam(true)
    for i = 0, 6 do
        local u = team:getTeamUnit(i)
        if u ~= nil and u:getTeamUnitCondition():findConditionWithType(95) ~= nil then
            table.insert(list, u)
        end
    end
    return list
end

local function OrdeusDeathScene(config)
    config = config or {}
    local cinematic = (config.cinematic ~= false)
    local pick = config.pick or 'none'
    local grabOrbit = config.grabOrbit or 'skill3player'

    local component = { name = 'OrdeusDeathScene' }

    local function onLoad(self, event)
        self._odsCastCount = 0
        self._odsDeathTarget = nil
        self._odsDeathExec = false
        self._odsFadeOutFlag, self._odsFadeOutFrame = false, 0
        self._odsTargetFadeInFlag, self._odsTargetFadeInFrame = false, 0
        self._odsFadeInFlag, self._odsFadeInFrame = false, 0
    end

    -- 全停止: 味方を復帰→気絶→初期位置へ寄せ、全体 pause。ボスだけ動く
    local function generalPause(self, event)
        self._odsDeathExec = true
        local team = battle():getTeam(true)
        for i = 0, 6 do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                u:resumeUnit()
                u:getTeamUnitCondition():addCondition(STUN_ID, 89, 100, 20, 0)
                u:setPositionX(u:getPositionX() + 150)
            end
        end
        battle():pauseUnit(2)
        event.unit:resumeUnit()
        event.unit.m_IgnoreHitStopTime = 10
    end

    -- 対象選出（ホスト決定→同期）＋全体フェードアウト開始
    local function target(self, event)
        if self.isHostPlayer and pick == 'cursed' then
            local cursed = collectCursed()
            if #cursed > 0 then
                local u = cursed[LuaUtilities.rand(1, #cursed)]
                self:hostDecide('ordeusPick', u:getIndex())
            end
        end
        self._odsFadeOutFrame = 0
        self._odsFadeOutFlag = true
    end

    -- 掴み: 対象をボス前へ座標移動し、対象位置に演出オービットを置いてフェードイン開始
    local function fadeInTarget(self, event)
        local targetUnit = self._odsDeathTarget
        if targetUnit == nil then
            return
        end
        self._odsTargetFadeInFrame = 0
        self._odsTargetFadeInFlag = true
        local destinationX = event.unit:getPositionX() + 400
        local destinationY = event.unit:getPositionY() + 250
        local mainX = targetUnit:getSkeleton():getBoneWorldPositionX("MAIN")
        local mainY = targetUnit:getSkeleton():getBoneWorldPositionY("MAIN")
        targetUnit:setPosition(destinationX - mainX, targetUnit:getPositionY())
        targetUnit:getSkeleton():setPositionY(destinationY - (mainY + targetUnit:getPositionY()))
        local fire = event.unit:addOrbitSystem(grabOrbit, 0)
        fire:setPosition(
            targetUnit:getPositionX() + targetUnit:getSkeleton():getBoneWorldPositionX("MAIN"),
            targetUnit:getPositionY() + targetUnit:getSkeleton():getPositionY()
                + targetUnit:getSkeleton():getBoneWorldPositionY("MAIN") + UNIT_HEIGHT)
        fire:pauseUnit(0.01)
    end

    -- 演出中の pause 維持（毎フレーム系 spine イベント）
    local function specialUpdate(self, event)
        if not self._odsDeathExec then
            return
        end
        battle():pauseUnit(0.5)
        event.unit:resumeUnit()
        event.unit:setInvincibleTime(1)
    end

    -- Hit: （cinematic なら）復帰の儀式 → onHit 効果
    local function death(self, event)
        if cinematic then
            self._odsDeathExec = false
            self._odsFadeInFrame = 0
            self._odsFadeInFlag = true
            event.unit:resumeUnit()
            event.unit.m_IgnoreHitStopTime = 0
            battle():setBattleState(kBattleState_active)
            event.unit:setInvincibleTime(0)
            local team = battle():getTeam(true)
            for i = 0, 4 do
                local u = team:getTeamUnit(i)
                if u ~= nil then
                    u:getTeamUnitCondition():addCondition(STUN_ID, 0, 0, 0.1, 0)   -- 行動リセット用の短時間コンディション
                end
            end
        end
        self._odsCastCount = self._odsCastCount + 1
        event.castCount = self._odsCastCount
        event.pickedUnit = self._odsDeathTarget
        event.cursedUnits = collectCursed()
        Action.runActions(self, event, config.onHit)
        self._odsDeathTarget = nil
    end

    local function onRun(self, event)
        local ev = event.spineEvent
        if ev == 'death' then
            death(self, event)
        elseif cinematic then
            if ev == 'generalPause' then
                generalPause(self, event)
            elseif ev == 'target' then
                target(self, event)
            elseif ev == 'fadeInTarget' then
                fadeInTarget(self, event)
            elseif ev == 'specialUpdate' then
                specialUpdate(self, event)
            end
        end
    end

    -- フェード処理（update 駆動。原作の fadeOutUpdate/fadeInTargetUpdate/fadeInUpdate）
    local function onUpdate(self, event)
        if self._odsFadeOutFlag == nil then
            return
        end
        local frameRate = event.deltaTime / ONE_FRAME
        if self._odsFadeOutFlag then
            local team = battle():getTeam(true)
            for i = 0, 6 do
                local u = team:getTeamUnit(i)
                if u ~= nil then
                    local opa = u:getOpacity() - 10 * frameRate
                    if opa < 0 then opa = 0 end
                    u:setOpacity(opa)
                end
            end
            self._odsFadeOutFrame = self._odsFadeOutFrame + frameRate
            if self._odsFadeOutFrame > 255 / 10 then
                self._odsFadeOutFlag = false
            end
        elseif self._odsTargetFadeInFlag then
            local u = self._odsDeathTarget
            if u ~= nil then
                local opa = u:getOpacity() + 6 * frameRate
                if opa > 255 then opa = 255 end
                u:setOpacity(opa)
            end
            self._odsTargetFadeInFrame = self._odsTargetFadeInFrame + frameRate
            if self._odsTargetFadeInFrame > 255 / 6 then
                self._odsTargetFadeInFlag = false
            end
        elseif self._odsFadeInFlag then
            local team = battle():getTeam(true)
            for i = 0, 6 do
                local u = team:getTeamUnit(i)
                if u ~= nil then
                    local opa = u:getOpacity() + 6 * frameRate
                    if opa > 255 then opa = 255 end
                    u:setOpacity(opa)
                end
            end
            self._odsFadeInFrame = self._odsFadeInFrame + frameRate
            if self._odsFadeInFrame > 255 / 6 then
                self._odsFadeInFlag = false
            end
        end
    end

    function component.initialize(dispatcher)
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel('ordeusPick', function(self, index)
            self._odsDeathTarget = battle():getTeam(true):getTeamUnit(index)
        end)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        if cinematic then
            dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        end
    end

    return component
end

_G.package.loaded[_NAME] = OrdeusDeathScene
return OrdeusDeathScene
