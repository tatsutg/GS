package.path = "dlc/additional/lib/?.lua;additional/lib/?.lua;dlc/additional/?.lua;additional/?.lua"
package.loaded = {};

_G.summoner = require("summoner")
local logger = summoner.Logger:new("AiParameter.lua")


--[[サブ条件タイプを変える、変えない場合は-1を返すこと]]
function aiSettingSubType(condId, param, paramType)
    for _,v in pairs(timerCondID()) do
        if condId == v then
            if param == 3 then
                return 1;
            end
            if param == 4 then
                return 2;
            end
        end
    end

    for _,v in pairs(unitModeCondId()) do
        if condId == v then
            return 3;
        end
    end

    local ret = -1;
    for _,v in pairs(changeSubTypeParameterTypes()) do
        if paramType == v then
            ret = param;
        end
    end

    return ret;
end

--[[Valueを変える、デフォルトでは1になっている。-1以外を返したら変更]]
function aiSettingValue(condId, param, masterParamType)
    for _,v in pairs(timerCondID()) do
        if condId == v then
            if param == 4 then
                return 0;
            end
        end
    end

    for _,v in pairs(unitModeCondId()) do
        if condId == v then
            return param;
        end
    end

    local ret = -1;
    for _,v in pairs(valueParameterTypes()) do
        if masterParamType == v then
            ret = param;
        end
    end
    return ret;
end

--[[ターゲットを変える、デフォルトではラーニングの場合は敵、そうでない場合は自身になっている。
自身＝１、パーティの誰か＝６、敵の誰か＝９、ボス＝１０]]
function aiSettingTarget(condId, target, param, paramType)
    local ret = target;
    for _,v in pairs(changeTarget9()) do
        if condId == v then
            ret = 9;
        end
    end

    for _,v in pairs(changeTargetParameterTypes()) do
        if paramType == v then
            ret = param;
        end
    end
    return ret;
end

---タイマー系の条件の調整用
function timerCondID()
    local condList = {
        50001,
        50002,
        50003,
        50004,
        50005,
        50006,
        50007,
        50035,
        50036,
        50037,
        50038,
        50050
    }
    return condList
end

---ユニットのモードが絡むCondId
function unitModeCondId()
    local idList = {
        50039,
        50041
    }
    return idList
end

---サブタイプを変えたいParamType
function changeSubTypeParameterTypes()
    local condList = {
        3,
        10,
        30,
        1002,
        1003,
        1004
    }
    return condList
end

---AIパラメータマスタの数値をつかいたいパラメータタイプ
function valueParameterTypes()
    local list = {
        5,
        6,
        7,
        8,
        15,
        17,
        18,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        37,
        38
    }
    return list
end

---ターゲットを変えたいParamType
function changeTargetParameterTypes()
    local condList = {
        2,
        4,
        11,
        13
    }
    return condList
end

---「敵の誰か」を判定対象にする
function changeTarget9()
    local condList = {
        50017,
        50026
    }
    return condList
end


function bridgeAiScript(unit, funcName, funcArgs, aiCondId, aiParameters)
    if summoner.AI.has(funcName) then
        local FLG = true
        if funcArgs[1] ~= "" then
            if unit:getEnemyID() ~= tonumber(funcArgs[1]) then
                FLG = false
            end
        end
        if FLG then
            local ret = summoner.AI.Functions[funcName](unit, funcArgs, aiCondId, aiParameters)
            if ret then
                return 1
            else
                return 0
            end
        end
    end
    return 0
end

function aiLearningDropCheck(funcName, funcArgs, aiCondId)
    print("CALL_AI_LEARNING_DROP_CHECK!!!!!!!!!!!!!!!");
    local team = megast.Battle:getInstance():getTeam(false);
    for i= 0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil then
            if target:getEnemyID() == tonumber(funcArgs[1]) then
                if summoner.AI.has(funcName) then
                    local ret = summoner.AI.Functions[funcName](target, funcArgs, aiCondId, nil)
                    if ret then
                        megast.Battle:getInstance():addAiLearningDropItem(target)
                        return 1
                    else
                        return 0
                    end
                end
            end
        end
    end

    return 0
end
