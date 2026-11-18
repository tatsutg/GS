------
-- Class for generating random data
------
local ipairs = ipairs
local math = math
local os = os
local pairs = pairs
local table = table

local _NAME = "summoner.Random"
local _M = {}
local _G = _G

math.randomseed(os.time())
for _ = 1, 10 do math.random() end

------
-- An alias for LuaUtilities.rand
-- @param number min
-- @param number max
-- @return number
------
_M.range = (LuaUtilities and LuaUtilities.rand) or function(min, max)
    if max == nil then
        max = min
        min = 0
    end
    local n = math.random(min, max - 1)
    return n
end
_M.generate = _M.range

------
-- Produce a random sample from the list
-- @param table list
-- @return mixed
------
function _M.sample(list)
    local lastIndex = table.maxn(list)
    if lastIndex < 1 then
        return nil
    end
    local sampleIndex = _M.range(0, lastIndex) + 1
    local x = list[sampleIndex]
    return x
end

------
-- Produce a random sample from the WEIGHTED list
-- @example
--     local x = summoner.Random.sampleWeighted({a=50, b=30, c=20})
--
-- @param table weightedList
-- @return mixed
------
function _M.sampleWeighted(weightedList)
    local totalWeight = 0
    local keyValuePairs = {}
    for key, weight in pairs(weightedList) do
        totalWeight = totalWeight + weight
        table.insert(keyValuePairs, {
            key = key,
            weight = weight
        })
    end
    if totalWeight < 1 then
        return nil
    end
    local randomNumber =  _M.range(0, totalWeight) + 1
    local currentWeight = 0
    for i, pair in ipairs(keyValuePairs) do
        currentWeight = currentWeight + pair.weight
        if currentWeight >= randomNumber then
            return pair.key
        end
    end
end

_G.package.loaded[_NAME] = _M
return _M
