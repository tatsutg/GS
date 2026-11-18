local _NAME = "summoner.AI"
local _M = {}
local _G = _G

local Logger = require("summoner.Logger")

_M.Functions = {}
_M.has = function(funcName)
    if funcName == nil then
        return false
    end
    if _M.Functions[funcName] == nil then
        return false
    else
        return true
    end
end

_M.Functions.MAGIADRIVE= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        if unit:getBattleStatusTimerBackImagePath() == "battle_magia_d_time.png" then
            return true
        end
    end
    return false
end

_M.Functions.MAGIAUNLIMITED= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        if unit:getBattleStatusTimerBackImagePath() == "battle_magia_a_time.png" then
            return true
        end
    end
    return false
end

_M.Functions.MAKETHUKAKUSEI= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        if unit:getBattleStatusTimerBackImagePath() == "battle_makethukakusei_time.png" then
            return true
        end
    end
    return false
end

_M.Functions.KAIGAN= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        if unit:getBattleStatusTimerBackImagePath() == "battle_kaigan_time.png" then
            return true
        end
    end
    return false
end

_M.Functions.SHINKAIGAN= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        if unit:getBattleStatusTimerBackImagePath() == "battle_shinkaigan_time.png" then
            return true
        end
    end
    return false
end

_M.Functions.USETIMER= function(unit, funcArgs, aiCondId, aiParameters)
    if unit:isVisibleBattleStatusTimer() then
        return true
    end
    return false
end

_M.Functions.HP_SKILL= function(unit, funcArgs, aiCondId, aiParameters)
    local bool = false
    local valueBox = {}
    local condition = unit:getTeamUnitCondition():findConditionWithID((aiCondId * 100) + funcArgs[2])
    if condition == nil then
        ---初回だけ通る
        condition = unit:getTeamUnitCondition():addCondition((aiCondId * 100) + funcArgs[2],0,1,99999,0);
        for i = 1,5 do valueBox[i] = 0 end
        for i,v in ipairs(funcArgs) do
            if i ~= 1 then
                valueBox[i-1] = tonumber(v)
            end
        end
    else
        ---初回以降通る
        valueBox[1] = condition:getValue1()
        valueBox[2] = condition:getValue2()
        valueBox[3] = condition:getValue3()
        valueBox[4] = condition:getValue4()
        valueBox[5] = condition:getValue5()
    end
    ---奥義中か確認
    if unit:getUnitState() == kUnitState_skill then
        ---HPフラグ関係ない奥義の場合、奥義終了まで判定しない
        local flgBuff = unit:getTeamUnitCondition():findConditionWithID(aiCondId)
        if flgBuff == nil then
            for i,v in ipairs(valueBox) do
                if not unit:getIsHpMarkerActive(valueBox[i] / 100) and valueBox[i] > 0 then
                    ---特定のHPマーカーが消えていて奥義中の場合
                    local keyBuff = unit:getTeamUnitCondition():addCondition(aiCondId * -1,0,valueBox[i],99999,0);
                    keyBuff:setRemoveOnResetState(true);
                    valueBox[i] = valueBox[i] * -1
                    break;
                end
            end
            ---判定しないためのフラグ付与
            local keyBuff = unit:getTeamUnitCondition():findConditionWithID(aiCondId * -1)
            if keyBuff == nil then
                local newBuff = unit:getTeamUnitCondition():addCondition(aiCondId,0,0,99999,0);
                newBuff:setRemoveOnResetState(true);
            end
        end
    end
    ---キー設定
    local keyBuff = unit:getTeamUnitCondition():findConditionWithID(aiCondId * -1)
    if keyBuff ~= nil then
        bool = true
    end
    condition:setValue1(valueBox[1]);
    condition:setValue2(valueBox[2]);
    condition:setValue3(valueBox[3]);
    condition:setValue4(valueBox[4]);
    condition:setValue5(valueBox[5]);
    return bool
end

_G.package.loaded[_NAME] = _M
return _M
