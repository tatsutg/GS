------
-- summoner.Choreo.Components.StatusErosion
--
-- 状態異常が長引くほど能力を削る: 指定の状態異常が付いているユニットに、付いている間 every 秒ごとに
-- バフ（最大HP% ダウン等）を同じ condition ID へ積み増す。積んだ分は戻らない（永続。戦闘不能で消える）。
-- アイコンには積んだ量の numberPer ごとの数字を出す（既定 10＝10% ごとに 1）。
-- 出典: enemy/2078896.lua（猛餓獣樹ゴロンドーラ）の壊毒（poisonBuffCheck → execAddTimeBuff2。毒90＋アイコン301 の
--   あいだ 1秒ごとに 最大HP(2) -0.75・防御力(15) -1 を同じ ID に積み、数字は積んだ量の 10% ごと）。
--
-- ⚠ update を使うため version >= 1.1。
-- ⚠ units の leader / others は getIsLeader() で判定する（Targeting の leader と違い、リーダーが戦闘不能でも
--    ほかのユニットへ移らない）。マルチでは getIsLeader が index 0 固定（全端末で同じ1体）。
-- ⚠ 最大HP% を積み続けて 1 を下回る分はエンジンが 1 に丸める（TeamUnit::getCalcHPMAX）。積み増しは止めない。
-- ⚠ 経過秒は状態異常が付いている対象のあいだだけ数える（外れる・戦闘不能・対象外になると 0 に戻す）。
-- ⚠ 同期不要: 状態異常は全端末で同じに見え、付ける condition は端末ローカルで決定的（host 分岐すると desync）。
--    プレイヤーへの付与は hostDecide を経由せず addCondition を直接呼ぶ。
--
-- 設定:
--   key        string        Start/StopStatusErosion で指す名前（既定 "default"。複数置くときは分ける）
--   types      number|table  見る condition type（いずれか）
--   icon       number        (任意) アイコン（thumbnail）も一致するものだけ見る（壊毒＝毒90＋アイコン301 の見分け）
--   every      number        積む間隔（秒。既定 1）
--   units      string        積む相手 'all'(既定) | 'leader' | 'others'（リーダー以外）
--   buffs      table         1回ごとに積むバフの列 { { id=, type=, value=, icon=, time= }, ... }
--                            value は1回ぶん（同じ id の現在値に足す）。time は既定 999999（永続）
--   numberPer  number        アイコンの数字の刻み（既定 10。0 で数字を出さない）
--   maxNumber  number        数字の上限（既定 99）
--   active     bool          開幕から積むか（既定 true。false なら StartStatusErosion で始める）
--   side       string        見るチーム 'player'(既定) | 'enemy'
--   slots      number        走査する枠数（既定 8）
--
-- Action:
--   StartStatusErosion{ key }  積み始める（経過秒は 0 から数える）
--   StopStatusErosion{ key }   止める（積んだ分は残る）
--
-- @example 幻炎（メテオヘイズ）: 猛炎のあいだ、HP50% まではリーダーの最大HPを 2%/秒、以降はリーダー以外を
--          1%/秒下げ、HP0% で止める
--     boss:add(StatusErosion{ key = 'leader', types = 208, icon = 308, units = 'leader',
--                             buffs = { { id = 208579621, type = 2, value = -2, icon = 2 } } })
--     boss:add(StatusErosion{ key = 'others', types = 208, icon = 308, units = 'others', active = false,
--                             buffs = { { id = 208579621, type = 2, value = -1, icon = 2 } } })
--     boss:add(Phases{ { at = 50, actions = { StopStatusErosion{ 'leader' }, StartStatusErosion{ 'others' } } } })
------
local _NAME = 'summoner.Choreo.Components.StatusErosion'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local STATE_PREFIX = '_statusErosion_'
local DEFAULT_KEY = 'default'

-- 状態異常が付いているか（icon 指定時はアイコンも一致するものだけ）
local function hasStatus(unit, types, icon)
    local cond = unit:getTeamUnitCondition()
    if icon == nil then
        for i = 1, #types do
            if cond:findConditionWithType(types[i]) ~= nil then return true end
        end
        return false
    end
    local size = cond:getAllConditionsSize()
    for i = 0, size - 1 do
        local c = cond:getAllConditionsAt(i)
        if c ~= nil and c:getThumbnailID() == icon then
            local t = c:getConditionTypeAsInt()
            for j = 1, #types do
                if t == types[j] then return true end
            end
        end
    end
    return false
end

local function isTarget(unit, units)
    if units == 'leader' then return unit:getIsLeader() end
    if units == 'others' then return not unit:getIsLeader() end
    return true
end

-- 1回ぶん積む（同じ id の現在値に足す）。アイコンに数字を出したら true
local function erode(unit, buffs, numberPer, maxNumber)
    local cond = unit:getTeamUnitCondition()
    local shown = false
    for i = 1, #buffs do
        local b = buffs[i]
        local old = cond:findConditionWithID(b.id)
        local value = ((old ~= nil) and old:getValue() or 0) + b.value
        local buff = cond:addCondition(b.id, b.type, value, b.time or 999999, b.icon or 0)
        if buff ~= nil and numberPer > 0 then
            -- 小数の積み増し（-0.75 等）の誤差で刻みの手前に留まらないよう、わずかに足してから切り捨てる
            local n = math.floor(math.abs(value) / numberPer + 1e-6)
            if n > maxNumber then n = maxNumber end
            if n > 0 then
                buff:setMaxConditionIconNumber(maxNumber)
                buff:setNumber(n)
                shown = true
            end
        end
    end
    return shown
end

local makeStatusErosion

local StatusErosion = setmetatable({}, {
    __call = function(_, config) return makeStatusErosion(config) end
})

function makeStatusErosion(config)
    config = config or {}
    local stateKey = STATE_PREFIX .. (config.key or DEFAULT_KEY)
    local types = config.types
    if type(types) ~= 'table' then types = { types } end
    local icon = config.icon
    local every = config.every or 1
    local units = config.units or 'all'
    local buffs = config.buffs or {}
    local numberPer = config.numberPer or 10
    local maxNumber = config.maxNumber or 99
    local startActive = config.active ~= false
    local isPlayerSide = config.side ~= 'enemy'
    local slots = config.slots or 8

    local component = { name = 'StatusErosion' }

    -- per-instance（規約 §6-3）。timers[枠番号] = 状態異常が付いてからの経過秒（前回積んでからの端数）
    local function onLoad(self, event)
        self[stateKey] = { active = startActive, timers = {} }
    end

    local function onUpdate(self, event)
        local st = self[stateKey]
        if st == nil or not st.active then return end
        local dt = event.deltaTime or 0
        local team = megast.Battle:getInstance():getTeam(isPlayerSide)
        local shown = false
        for i = 0, slots - 1 do
            local u = team:getTeamUnit(i)
            if u ~= nil and isTarget(u, units) and hasStatus(u, types, icon) then
                local t = (st.timers[i] or 0) + dt
                if t >= every then
                    t = t - every
                    if erode(u, buffs, numberPer, maxNumber) then shown = true end
                end
                st.timers[i] = t
            else
                st.timers[i] = 0
            end
        end
        if shown then
            megast.Battle:getInstance():updateConditionView()
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

-- 積み始める（HPフェーズ等から）。経過秒は 0 から数える
StatusErosion.Start = Action.define('StartStatusErosion', function(a, d, e)
    local st = d[STATE_PREFIX .. (a.key or a[1] or DEFAULT_KEY)]
    if st == nil then return end
    st.active = true
    st.timers = {}
end)

-- 止める。積んだ分はそのまま残る
StatusErosion.Stop = Action.define('StopStatusErosion', function(a, d, e)
    local st = d[STATE_PREFIX .. (a.key or a[1] or DEFAULT_KEY)]
    if st == nil then return end
    st.active = false
    st.timers = {}
end)

_G.package.loaded[_NAME] = StatusErosion
return StatusErosion
