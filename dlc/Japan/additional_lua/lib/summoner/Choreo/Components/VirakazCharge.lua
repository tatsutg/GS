------
-- summoner.Choreo.Components.VirakazCharge
--
-- ヴィラカーズ種の「力溜め」: StartVirakazCharge で溜めに入り、溜め中はゲージを時間で貯め、
-- 満タンで指定奥義を撃つ。溜め中に指定の状態異常（既定 毒/暗闇/病気）かブレイクを受けると解除され、
-- 気絶して奥義ゲージ0。解除に使われた状態異常は以後の耐性として積み上がる。
-- 出典: enemy/2064525.lua（魔族遺跡 ヴィラカーズhard）の chargeStart / update / badConditionCheck /
--   chargingStop / antiBadCondition / takeDamageValue / takeBreake 一式。2064520 は継承。
--
-- 流れ:
--   開始（StartVirakazCharge）: 状態異常(89-97)を消す → 現ゲージを保存して0へ → 次の奥義を skill に強制 →
--     setUnitState(attack) で行動を止め、charge_loop をループ再生 → onStart
--   溜め中: interval 秒ごとに sp 加算（ホスト）。被ダメ × damageRate。満タンでエンジンが奥義 skill を撃つ
--   完了: 奥義が出たら溜め終了。保存したゲージは奥義の後に戻る（Smash の keepGauge と同じ仕組み）
--   解除: 対象状態異常 or ブレイク → 気絶 stun.time 秒・ゲージ0・強制奥義の取り消し → onCancel。
--     状態異常で解除されたら、その種類の耐性を resist.value × 回数（最大 resist.max）で付与し、
--     気絶が明けたときに resistMessages を表示する
--
-- ⚠ Smash 必須（強制奥義とゲージ保存に使う）。update/takeDamageValue/takeBreake を使うため boss version >= 1.3。
-- ⚠ 解除判定はホストが行い、Sync チャンネルで全端末へ配信する（原作は各端末で判定していた）。
-- ⚠ 原作どおり、解除されても保存したゲージは捨てない＝解除後に最初に撃った奥義の後で戻る。
-- ⚠ 原作が指定するエフェクト charge_short は 50125ef に無い（本番でも出ていない）ため effect の既定は無し。
--    ef 側のループは charge_loop。
--
-- 設定:
--   skill          number   溜め完了で撃つ奥義（Smash のスロット番号）。必須
--   damageRate     number   溜め中の被ダメージ倍率（既定 0.08）
--   interval       number   ゲージ加算の間隔秒（既定 1.5）
--   sp             number   1回の加算量（既定 20）
--   statuses       table    解除する状態異常の type（既定 { 90, 93, 94 }＝毒・暗闇・病気）
--   cancelOnBreak  bool     ブレイクで解除（既定 true）
--   anim           string   溜め中の本体ループアニメ（既定 "charge_loop"）
--   effect         string   溜め中のエフェクトループアニメ（既定 無し）
--   stun           table    解除時の気絶 { id=, time=, icon= }（既定 原作の 20645252 / 3秒 / 79）
--   resist         table    耐性の積み上げ { id=, value=, max= } または false で無効
--                           （既定 原作の 206452500 / 100 / 3。付与 ID は id + 種別で決まる）
--   resistMessages table    耐性が付いた後の INFO { [type] = { key=, text= } } または false
--                           （既定 原作の RESIST_MESSAGE1-3「毒/暗闇/病気耐性アップ」・赤）
--   onStart        Action|list  溜め開始時（「力を溜めている……」等）
--   onCancel       Action|list  解除時（「力溜め解除成功！」等）。event.statusType に原因（ブレイク時 0）
--
-- @example
--     boss:add(VirakazCharge{ skill = 6,
--         onStart = { Say{ "力を溜めている……", color = 'red' } },
--         onCancel = { Say{ "力溜め解除成功！", color = 'white' } } })
--     boss:add(Phases{ { at = 70, stop = true, actions = { StartVirakazCharge{} } } })
------
local _NAME = 'summoner.Choreo.Components.VirakazCharge'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')
local Message = require('summoner.Choreo.Message')
local Color = require('summoner.Color')

local CHANNEL = 'virakazCharge'

-- 原作 2064525 の解除状態異常と、耐性バフの組（原作 antiBadCondition: type-37 の耐性 ＋ その +49 の副効果）
local DEFAULT_STATUSES = { 90, 93, 94 }
local DEFAULT_RESIST_MESSAGES = {
    [90] = { key = 'RESIST_MESSAGE1', text = '毒耐性アップ' },
    [93] = { key = 'RESIST_MESSAGE2', text = '暗闇耐性アップ' },
    [94] = { key = 'RESIST_MESSAGE3', text = '病気耐性アップ' },
}

local makeVirakazCharge

local VirakazCharge = setmetatable({}, {
    __call = function(_, config) return makeVirakazCharge(config) end
})

-- 状態異常(89-97)を時間切れにして消す（原作 removeBadCondition）
local function clearBadStatus(unit)
    local cond = unit:getTeamUnitCondition()
    local size = cond:getAllConditionsSize()
    for i = 0, size - 1 do
        local c = cond:getAllConditionsAt(i)
        if c ~= nil then
            local t = c:getConditionTypeAsInt()
            if t >= 89 and t <= 97 then
                c:setTime(0)
            end
        end
    end
end

-- 自身に付いている解除対象の状態異常 type（効果量 > 0）を返す。無ければ nil
local function findCancelStatus(unit, statuses)
    local cond = unit:getTeamUnitCondition()
    local size = cond:getAllConditionsSize()
    for i = 0, size - 1 do
        local c = cond:getAllConditionsAt(i)
        if c ~= nil and c:getValue() > 0 then
            local t = c:getConditionTypeAsInt()
            for j = 1, #statuses do
                if t == statuses[j] then
                    return t
                end
            end
        end
    end
    return nil
end

function makeVirakazCharge(config)
    config = config or {}
    assert(config.skill ~= nil, 'VirakazCharge: skill（溜め完了で撃つ奥義のスロット番号）が必要')
    local skill = config.skill
    local damageRate = config.damageRate or 0.08
    local interval = config.interval or 1.5
    local sp = config.sp or 20
    local statuses = config.statuses or DEFAULT_STATUSES
    local cancelOnBreak = config.cancelOnBreak ~= false
    local anim = config.anim or 'charge_loop'
    local effect = config.effect
    local stun = config.stun or {}
    local stunID = stun.id or 20645252
    local stunTime = stun.time or 3
    local stunIcon = stun.icon or 79
    local resist = config.resist
    if resist == nil then resist = {} end
    local resistID = resist and (resist.id or 206452500)
    local resistValue = resist and (resist.value or 100)
    local resistMax = resist and (resist.max or 3)
    local resistMessages = config.resistMessages
    if resistMessages == nil then resistMessages = DEFAULT_RESIST_MESSAGES end

    local component = { name = 'VirakazCharge' }

    -- 耐性を1段積む（原作 badConditionCheck → antiBadCondition）
    local function addResist(unit, statusType)
        local buffType = statusType - 37
        local cond = unit:getTeamUnitCondition()
        local count = 1
        local old = cond:findConditionWithID(resistID + buffType)
        if old ~= nil then
            count = old:getNumber() + 1
            if count > resistMax then count = resistMax end
        end
        local value = resistValue * count
        local pair = {
            { id = resistID + buffType, type = buffType, icon = buffType + 6 },
            { id = resistID + buffType + 49, type = buffType + 49, icon = 0 },
        }
        for i = 1, #pair do
            local c = cond:addCondition(pair[i].id, pair[i].type, value, 99999, pair[i].icon)
            if c ~= nil then
                c:setMaxConditionIconNumber(resistMax)
                c:setNumber(count)
            end
        end
        megast.Battle:getInstance():updateConditionView()
    end

    -- 解除（全端末で実行。statusType=0 はブレイク）
    local function cancel(self, statusType)
        if not self._virakazCharging then return end
        local unit = self.unit
        self._virakazCharging = false
        self._virakazTimer = 0
        self:forceSmash(nil)                      -- 強制奥義を取り消す（通常ローテへ戻す）
        unit:getTeamUnitCondition():addCondition(stunID, 89, 100, stunTime, stunIcon)
        unit:setBurstPoint(0)
        if statusType ~= 0 and resist then
            addResist(unit, statusType)
            self._virakazResistPending = statusType
        end
        Action.runActions(self, { unit = unit, statusType = statusType }, config.onCancel)
    end

    -- 溜め開始（StartVirakazCharge から。全端末で実行）
    local function start(self)
        local unit = self.unit
        clearBadStatus(unit)
        self:armSmashGauge()                      -- 現ゲージを保存（次の奥義の後で戻る）
        unit:setBurstPoint(0)
        self:forceSmash(skill)
        unit:setUnitState(kUnitState_attack)
        unit:takeAnimation(0, anim, true)
        if effect ~= nil then
            unit:takeAnimationEffect(0, effect, true)
        end
        self._virakazCharging = true
        self._virakazTimer = 0
        Action.runActions(self, { unit = unit }, config.onStart)
    end
    component.startVirakazCharge = start

    local function onLoad(self, event)
        self._virakazCharging = false
        self._virakazTimer = 0
        self._virakazResistPending = nil
    end

    local function onUpdate(self, event)
        local unit = event.unit or self.unit
        if self._virakazCharging then
            if self.isHostPlayer then
                local t = findCancelStatus(unit, statuses)
                if t ~= nil then
                    self:hostDecide(CHANNEL, t)
                    return
                end
                self._virakazTimer = self._virakazTimer + (event.deltaTime or 0)
                if self._virakazTimer > interval then
                    self._virakazTimer = self._virakazTimer - interval
                    unit:addSP(sp)
                end
            end
        elseif self._virakazResistPending ~= nil then
            -- 気絶が明けたら耐性 INFO（原作 update の saveTypeId 分岐）
            if unit:getTeamUnitCondition():findConditionWithID(stunID) == nil then
                local m = resistMessages and resistMessages[self._virakazResistPending]
                self._virakazResistPending = nil
                if m ~= nil then
                    local text = m.text
                    if m.key ~= nil and self.TEXT ~= nil and self.TEXT[m.key] ~= nil then
                        text = self.TEXT[m.key]
                    end
                    Message{ text = text, color = m.color or Color.red }:show()
                end
            end
        end
    end

    local function onDamage(self, event)
        if self._virakazCharging then
            event.value = event.value * damageRate
        end
    end

    local function onBreak(self, event)
        if cancelOnBreak and self._virakazCharging and self.isHostPlayer then
            self:hostDecide(CHANNEL, 0)
        end
    end

    -- 奥義が出たら溜め終了（原作 takeSkill の isCharging=false）
    local function onSmash(self, event)
        self._virakazCharging = false
        self._virakazTimer = 0
    end

    function component.initialize(dispatcher)
        assert(dispatcher:hasComponent('Smash'), 'VirakazCharge: Smash を先に add すること（強制奥義とゲージ保存に使う）')
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel(CHANNEL, function(self, statusType)
            cancel(self, statusType)
        end)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
        dispatcher:addEventListener(Events.takeBreake, onBreak)
        dispatcher:addEventListener(Events.OnSmashCommit, onSmash)
    end

    return component
end

-- 溜めに入る（Phases の actions 等から）
VirakazCharge.Start = Action.define('StartVirakazCharge', function(a, d, e)
    d:startVirakazCharge()
end)

_G.package.loaded[_NAME] = VirakazCharge
return VirakazCharge
