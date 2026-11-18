------
-- summoner.Choreo.Buff
-- summoner.Choreo.Buff.Types
--
-- condition（バフ/デバフ/状態異常）の値オブジェクト。
-- Buff{...}:attach(unit) で getTeamUnitCondition():addCondition(...) 一式を行う。
-- Types で condition 種別番号に可読名を与える（マジックナンバー撲滅）。
--
-- 注: Action.AttachBuff はこの Buff をラップして宣言面を提供する。
------
local _NAME = "summoner.Choreo.Buff"
local _M = {}
local _G = _G

_M.DEFAULT_VALUE = 1
_M.DEFAULT_TIME = 9999
_M.DEFAULT_ICON = 0
_M.DEFAULT_GROUP = false      -- false=未指定（attach 時に効果タイプを採用）。重複ありは -1 を明示
_M.DEFAULT_PRIORITY = false   -- false=未指定（attach 時に value を採用＝強い方が勝つ）
_M.DEFAULT_EFFECT = false
_M.DEFAULT_SCRIPT_ID = false
_M.DEFAULT_SCRIPT_VALUE1 = false
_M.DEFAULT_SCRIPT_VALUE2 = false
_M.DEFAULT_SCRIPT_VALUE3 = false
_M.DEFAULT_SCRIPT_VALUE4 = false
_M.DEFAULT_SCRIPT_VALUE5 = false

------
-- summoner.Choreo.Buff のインスタンスを作る
-- @param table parameters
--     number id
--     number type
--     number(optional) time
--     number(optional) value
--     number(optional) icon
--     number(optional) effect
--     number(optional) scriptID
--     number(optional) scriptValue1..5
-- @return summoner.Choreo.Buff
------
setmetatable(_M, {__call=function(self, parameters)
    assert(type(parameters) == 'table', "bad argument #1 to 'Buff' (table expected, got " .. type(parameters) .. ')')
    assert(type(parameters.id) == 'number', "bad argument #1 at 'id' to 'Buff' (number expected, got " .. type(parameters.id) .. ')')
    assert(type(parameters.type) == 'number', "bad argument #1 at 'type' to 'Buff' (number expected, got " .. type(parameters.type) .. ')')

    local buff = setmetatable({}, {__index=self})
    buff.id = parameters.id
    buff.type = parameters.type
    buff.value = parameters.value or _M.DEFAULT_VALUE
    buff.time = parameters.time or _M.DEFAULT_TIME
    buff.icon = parameters.icon or _M.DEFAULT_ICON
    buff.group = parameters.group or _M.DEFAULT_GROUP
    buff.priority = parameters.priority or _M.DEFAULT_PRIORITY
    buff.effect = parameters.effect or _M.DEFAULT_EFFECT
    buff.scriptID = parameters.scriptID or _M.DEFAULT_SCRIPT_ID
    buff.scriptValue1 = parameters.scriptValue1 or _M.DEFAULT_SCRIPT_VALUE1
    buff.scriptValue2 = parameters.scriptValue2 or _M.DEFAULT_SCRIPT_VALUE2
    buff.scriptValue3 = parameters.scriptValue3 or _M.DEFAULT_SCRIPT_VALUE3
    buff.scriptValue4 = parameters.scriptValue4 or _M.DEFAULT_SCRIPT_VALUE4
    buff.scriptValue5 = parameters.scriptValue5 or _M.DEFAULT_SCRIPT_VALUE5

    return buff
end})

------
-- unit に condition として付与する
-- @param TeamUnit unit
-- @return Condition
------
function _M:attach(unit)
    local condition = nil
    if self.effect ~= false then
        condition = unit:getTeamUnitCondition():addCondition(self.id, self.type, self.value, self.time, self.icon, self.effect)
    else
        condition = unit:getTeamUnitCondition():addCondition(self.id, self.type, self.value, self.time, self.icon)
    end

    -- group 規約: 同じ種類のバフは同じグループ。**省略時の既定 = 効果タイプ**（同種=同グループを自動で満たす）。
    -- 重複あり（並存させたい）場合のみ group=-1 を明示。priority 省略時は value（強い方が勝つ）。
    -- ⚠ addCondition 既定の group 0 を放置しない（実グループ扱いで無関係なバフ同士が1枠を取り合う）。
    if condition ~= nil then
        condition:setGroupID(self.group ~= false and self.group or self.type)
        condition:setPriority(self.priority ~= false and self.priority or (self.value or 0))
    end

    if condition ~= nil and self.scriptID ~= false then   -- addCondition は枠あふれ/対象死亡で nil を返し得る（applyStacks と同様にガード）
        condition:setScriptID(self.scriptID)
        if self.scriptValue1 ~= false then condition:setValue1(self.scriptValue1) end
        if self.scriptValue2 ~= false then condition:setValue2(self.scriptValue2) end
        if self.scriptValue3 ~= false then condition:setValue3(self.scriptValue3) end
        if self.scriptValue4 ~= false then condition:setValue4(self.scriptValue4) end
        if self.scriptValue5 ~= false then condition:setValue5(self.scriptValue5) end
    end

    return condition
end

------
-- condition 種別の可読名（[04] / マスタ定義に対応）
------
_M.Types = {}
_M.Types.None = 0
_M.Types.BoostHealthLimit = 1 -- 最大HP固定値
_M.Types.BoostHealthLimitRate = 2 -- 最大HP割合
_M.Types.HealHealth = 3 -- HP回復固定値
_M.Types.HealHealthRate = 4 -- HP回復割合
_M.Types.HealHealthByAttackPower = 5 -- 回復（攻撃力割合）
-- 6 回復（対象の減少HP割合）
_M.Types.HealHealthOverTime = 7 -- HP自然回復(固定値)
_M.Types.BoostSmashMeter = 8 -- SP回復
-- 9 SP増加量
_M.Types.BoostSmashMeterOverTime = 10 -- SP自然増加
_M.Types.BoostSmashBallRate = 11 -- SP玉ドロップ率（％）
_M.Types.BoostAttackPower = 12 -- 攻撃力固定値
_M.Types.BoostAttackPowerRate = 13 -- 攻撃力割合
_M.Types.BoostDefensePower = 14 -- 防御力固定値
_M.Types.BoostDefensePowerRate = 15 -- 防御力割合
_M.Types.BoostDamage = 16 -- 与ダメージ固定値
_M.Types.BoostDamageRate = 17 -- 与ダメージ割合
-- 18 追加ダメージ固定値
-- 19 追加ダメージ割合
-- 20 被ダメージ固定値
-- 21 被ダメージ割合
_M.Types.BoostCriticalRate = 22 -- クリティカル率
_M.Types.BoostCriticalResistanceRate = 23 -- 被クリティカル率
_M.Types.BoostBreakPower = 24 -- ブレイク力固定値
_M.Types.BoostBreakPowerRate = 25 -- ブレイク力割合

_G.package.loaded[_NAME] = _M
return _M
