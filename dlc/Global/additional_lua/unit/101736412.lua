local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒アルシェ", version=1.3, id=101736412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.hpReduceValue = -15
    return 1
end

function class:runRelize(unit)
    local index = -1;
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i,true);
        if teamUnit ~= nil then
            if teamUnit:getHP() <= 0 then
                index = i;
                break;
            end
        end
    end
    if index ~= -1 then
        self:excuteRinascita(unit,index);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,index);
    end
    return 1;
end

function class:excuteRinascita(unit,index)
    local teamUnit = unit:getTeam():getTeamUnit(index,true);
    if teamUnit ~= nil then
        ---蘇生数をカウント
        local counter = 1;
        if teamUnit:getParameter("archeCount") ~= "" then
            counter = tonumber(teamUnit:getParameter("archeCount")) + 1;
        end
        teamUnit:setParameter("archeCount",counter.."");
        if not self:getIsControll(teamUnit) and not megast.Battle:getInstance():isPvp() then
            return;
        end
        ---蘇生処理
        unit:getTeam():reviveUnit(teamUnit:getIndex())
        ---即死しないようバリア
        if megast.Battle:getInstance():isPvp() then
            teamUnit:setWaitReviveTime(2)
        end
        teamUnit:getTeamUnitCondition():addCondition(-1,98,9999999,2,0);
        ---HP減少
        local cond = teamUnit:getTeamUnitCondition():findConditionWithID(100131);
        if cond ~= nil then
            cond:setValue(self.hpReduceValue * counter);
        else
            local cond = teamUnit:getTeamUnitCondition():addCondition(100131,2,self.hpReduceValue,9999,2);
            cond:setIsPassive(true);
        end
        megast.Battle:getInstance():updateConditionView();
        ---奥義ゲージアップ
        local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        teamUnit:setBurstPoint(teamUnit:getBurstPoint() + (100 * pvpCorrectionValue));
    end
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:excuteRinascita(self.gameUnit,args.arg);
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "runRelize" then
        self:runRelize(event.unit)
    end
    return 1
end

class:publish();

return class;