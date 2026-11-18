------
-- グランドバトルエネミーのステータス計算用のスクリプト
------
local _NAME = "GBEnemy"
local _M = {}
local _G = _G

local assert = assert
local ipairs = ipairs
local math = math
local pairs = pairs
local print = print
local setmetatable = setmetatable
local type = type

local STRING_TYPE = type("")
local NUMBER_TYPE = type(0)

print("[other/GBEnemy.lua]: Start loading")

------
-- 書き換えるステータスを定義する
-- string setter TeamUnitのステータスをセットするメソッド名
-- string formula1 GBEnemyMasterの数式１を取得するメソッド名
-- string formula2 GBEnemyMasterの数式２を取得するメソッド名
-- string inflection GBEnemyMasterから変曲点を取得するメソッド名
-- number scalar ステータスをセットするときにかける係数
------
_M.METHOD_SETS = {
    [1] = {
        setter = "setBaseHP",
        formula1 = "getHpFunction1",
        formula2 = "getHpFunction2",
        inflection = "getHpThreshold",
        scalar = 1,
    },
    [2] = {
        setter = "setBasePower",
        formula1 = "getAttackFunction1",
        formula2 = "getAttackFunction2",
        inflection = "getAttackThreshold",
        scalar = 1,
    },
    [3] = {
        setter = "setBaseDefence",
        formula1 = "getDeffenceFunction1",
        formula2 = "getDeffenceFunction2",
        inflection = "getDeffenceThreshold",
        scalar= 1,
    },
    [4] = {
        setter = "setBaseBreakCapacity",
        formula1 = "getBreakCapacityFunction1",
        formula2 = "getBreakCapacityFunction2",
        inflection = "getBreakCapacityThreshold",
        scalar = 1,
    },
}

------
-- エネミー生成時に呼ばれるグロール関数
-- 
-- @param TeamUnit unit
-- @param GBEnemyMaster master
-- @param number currentFloor
-- @param number currentWave
-- @param number maxWave
------
local function initGBEnemy(unit, master, currentFloor, currentWave, maxWave)
    print(("[initGBEnemy: %s(%s)"):format(unit:getUnitName(), unit:getUnitID()))
    print(("[initGBEnemy: a = `%s` -- currentFloor"):format(currentFloor))
    print(("[initGBEnemy: b = `%s` -- currentWave"):format(currentWave))
    print(("[initGBEnemy: c = `%s` -- maxWave"):format(maxWave))
    -- 数式のテンプレートを作る
    local formula = _M.Formula:new({
        a = currentFloor,
        b = currentWave,
        c = maxWave,
    })

    for index, set in ipairs(_M.METHOD_SETS) do
        local formula1 = master[set.formula1](master)
        local formula2 = master[set.formula2](master)

        local inflection = master[set.inflection](master)
        -- 1番目の数式を実行して値を取得する
        local result = formula:eval(formula1)
        -- 値が変曲点より大きければ、2番目の数式を実行して値を取得する
        if result > inflection then
            result = formula:eval(formula2)
        end
        -- ユニットのステータスを書き換える
        print(("    [initGBEnemy]: formula1 = `%s`"):format(formula1))
        print(("    [initGBEnemy]: formula2 = `%s`"):format(formula2))
        print(("    [initGBEnemy]: inflection = `%s`"):format(inflection))
        print(("    [initGBEnemy]: unit:%s(%s*%s)"):format(set.setter, result, set.scalar))
        print("")
        unit[set.setter](unit, result*set.scalar)
    end

    return 1
end

------
-- グランドバトル時、グランドバトルエネミーに対して付与されるConditionの効果値 Value を変更する
------
local function GBEnemy_ConditionOverrideValue(condition, master, currentFloor, currentWave, maxWave)
    print(("[GBEnemy_ConditionOverrideValue: %s(%s)"):format(condition:getID(), condition:getValue()))
    print(("[GBEnemy_ConditionOverrideValue: a = `%s` -- currentFloor"):format(currentFloor))
    print(("[GBEnemy_ConditionOverrideValue: b = `%s` -- currentWave"):format(currentWave))
    print(("[GBEnemy_ConditionOverrideValue: c = `%s` -- maxWave"):format(maxWave))

    -- 数式のテンプレートを作る
    local formula = _M.Formula:new({
        a = currentFloor,
        b = currentWave,
        c = maxWave,
    })

    local formula1 = master:getMineEffValFunction1()
    local formula2 = master:getMineEffValFunction2()

    print(("[GBEnemy_ConditionOverrideValue: getGBEffValFunction1 = `%s` -- "):format(master:getMineEffValFunction1()))
    print(("[GBEnemy_ConditionOverrideValue: getGBEffValFunction2 = `%s` -- "):format(master:getMineEffValFunction2()))

    -- 空だったらエラーにする
    assert(formula1 ~= "", ("GBEnemy_ConditionOverrideValue - getMineEffValFunction1 is empty at `%s`"):format(master:getId()))
    assert(formula2 ~= "", ("GBEnemy_ConditionOverrideValue - getMineEffValFunction2 is empty at `%s`"):format(master:getId()))

    local inflection = master:getMineEffValThreshold()
    -- 1番目の数式を実行して値を取得する
    local result = formula:eval(formula1)
    -- 値が変曲点より大きければ、2番目の数式を実行して値を取得する
    if result > inflection then
        result = formula:eval(formula2)
    end

    print(("[GBEnemy_ConditionOverrideValue: result = `%s` -- result"):format(result))
    condition:setValue(result)

    return 1
end



------
-- 数式を実行し、計算するクラス
------
local Formula = {}

-- 結果を代入するグロール変数の名前
Formula.VAR_NAME = "GB_ENEMY_FORMULA_RESULT"

------
-- Formulaクラスのコンストラクタ
-- @param table params
------
function Formula:new(params)
    local args = {}
    for name, value in pairs(params) do
        local valueType = type(value)
        assert(valueType == STRING_TYPE or valueType == NUMBER_TYPE, "Expected string or number")
        args[name] = value
    end
    local self_ = setmetatable({
        args = args
    }, {__index=self})
    return self_
end

------
-- 数式を実行して結果を返す
-- 少数は切り捨てる
-- @param table params
-- @return number
------
function Formula:eval(formulaString)
    local origin = {}
    for name, value in pairs(self.args) do
        -- 元のグロール変数の値をとっておく
        origin[name] = _G[name]
        -- グロール変数を書き換える
        _G[name] = value
    end
    -- 結果を代入するグロール変数の値もとっておく
    origin[self.VAR_NAME] = _G[self.VAR_NAME]

    -- 数式を実行して計算結果を取得する
    local formula = ("_G.%s = %s"):format(self.VAR_NAME, formulaString:gsub("%*%*", "^"))
    assert(loadstring(formula))()
    local result = _G[self.VAR_NAME]

    -- グロール変数を元の値に戻す
    for name, value in pairs(origin) do
        _G[name] = value
    end

    return math.floor(result)
end

_M.Formula = Formula
_G.initGBEnemy = initGBEnemy
_G.GBEnemy_ConditionOverrideValue = GBEnemy_ConditionOverrideValue

_G.package.loaded[_NAME] = _M
return _M
