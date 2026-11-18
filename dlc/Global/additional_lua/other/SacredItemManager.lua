------
-- 超神具のパラメーターを出したりいろいろするやつ
------
package.path = "dlc/additional/lib/?.lua;additional/lib/?.lua;dlc/additional/?.lua;additional/?.lua"
package.loaded = {};

local _NAME = "SacredItemManager"
local _M = {}
local _G = _G

_G.summoner = require("summoner")

local assert = assert
local ipairs = ipairs
local math = math
local pairs = pairs
local print = print
local setmetatable = setmetatable
local type = type
local string = string

local Json = summoner.import("Json")

local STRING_TYPE = type("")
local NUMBER_TYPE = type(0)

print("[other/SacredItemManager.lua]: Start loading")

------
-- 渡された値を元に 超神具用のステータス値 を返す
-- 
-- @param float base_value
-- @param string formula_value
------
local function getParamValue(base_value, formula_value)
    print(("[getParamValue: (%s) (%s)"):format(base_value,formula_value))

    -- 数式のテンプレートを作る
    local formula = _M.Formula:new({
        x = base_value,
    })
    assert(formula_value ~= "", ("SacredItemManager_getParamValue - formula_value is empty"))

    local result = formula:eval(formula_value)
    print(("[SacredItemManager_getParamValue: result = `%s` -- result"):format(result))

    return result
end

------
-- 数式を実行し、計算するクラス
------
local Formula = {}

-- 結果を代入するグロール変数の名前
Formula.VAR_NAME = "SACRED_ITEM_MANAGER_FORMULA_RESULT"

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


function rd0(x)
    if x < 0 then
        return math.floor(x*-1)*-1
    else
        return math.floor(x)
    end
end

function rd1(x)
    if x < 0 then
        return math.floor(x*-10)/-10
    else
        return math.floor(x*10)/10
    end
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

    return result
end


local function TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

------
-- skill_effect_masterの値でskill_masterの説明文を置換する。
--
-- フォーマットは下記
-- {KEY:FORMAT}
--
-- 効果値: v1, v2, v3, ...
-- 効果時間: t1, t2, t3, ...
-- 重み: w1, w2, w3, ...
--
-- テンプレートの例:
--     自身の魔法ダメージ{v1:.1f}%UP。クエスト開始から{t2:.1f}秒間、味方全体の炎属性ダメージ{v2:.1f}%UP
------
local function makeEffectText(template, effects, sortKey)
    if sortKey == nil then
        sortKey = 'id'
    end

    -- コピーしてID順でソート
    local copy = {unpack(effects)}
    table.sort(copy, function(a, b) return a[sortKey] < b[sortKey] end)

    -- 置換する値をマッピングする
    local replacers = {}
    for i, v in ipairs(copy) do
        replacers[ 'v' .. i] = v.value
        replacers['-v' .. i] = math.abs(v.value)
        replacers[ 't' .. i] = v.time
        replacers[ 'w' .. i] = v.weight
    end

    -- 置換した文字列を返す
    local text = string.gsub(template, '{([^:]+):([^}]+)}', function(name, fmt)
        return string.format('%' .. fmt, replacers[name])
    end)
    return text
end

------
-- 超神具用の説明文を生成する
-- 
-- @param - unsigned int - skillMasterId
-- @param - unsigned int - skillEffectMasterId
-- @param - float - value
-- @param - float - time
-- @param - float - weight
-- @param - string - description
------
local function formatDescription(jsondata)
    print(("[formatDescription: %s"):format(jsondata))
    local parseJson = Json.parse(jsondata)
    local skillMasterId = parseJson.skillMasterId
    local effectInfoArray = parseJson.effectInfoArray
    local description = parseJson.description

    return makeEffectText(description, effectInfoArray, 'skillEffectMasterId')
end



_M.rd0 = rd0
_M.rd1 = rd1
_M.Formula = Formula
_M.TableLength = TableLength
_G.getParamValue = getParamValue
_G.formatDescription = formatDescription

_G.package.loaded[_NAME] = _M
return _M
