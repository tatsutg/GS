local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP5_GB雷弓士ファル", version=2.5, id="gb_501301"});
class:inheritFromEnemy("gbBossBase");


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "SetHevnPanish" then self:SetHevnPanish(event.unit); end
    if event.spineEvent == "ResetHevnPanish" then self:ResetHevnPanish(event.unit); end
    if event.spineEvent == "Execution1" then self:Execution1(event.unit); end
    if event.spineEvent == "Execution2" then self:Execution2(event.unit); end
    if event.spineEvent == "Execution3" then self:Execution3(event.unit); end
    if event.spineEvent == "Execution4" then self:Execution4(event.unit); end
    if event.spineEvent == "Execution5" then self:Execution5(event.unit); end
    if event.spineEvent == "Execution6" then self:Execution6(event.unit); end
    if event.spineEvent == "Execution7" then self:Execution7(event.unit); end
    if event.spineEvent == "Execution8" then self:Execution8(event.unit); end
    if event.spineEvent == "ExecutionEx1" then self:ExecutionEx1(event.unit); end
    if event.spineEvent == "ExecutionEx2" then self:ExecutionEx2(event.unit); end
    return 1;
end

function class:SetHevnPanish(unit)
    -- unit:getTeamUnitCondition():addCondition(-12,0,0,2000,4);
    -- unit:getTeamUnitCondition():addCondition(-13,0,0,2000,0);
    -- unit:getTeamUnitCondition():addCondition(-14,0,0,2000,0);
    -- unit:getTeamUnitCondition():addCondition(-15,0,0,2000,0);
    return 1;
end

function class:ResetHevnPanish(unit)
    -- local conditon = unit:getTeamUnitCondition():findConditionWithID(-12);
    -- unit:getTeamUnitCondition():removeCondition(conditon);
    return 1;
end

function class:Execution1(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(50,0);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end

function class:Execution2(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(200,-90);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end

function class:Execution3(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(-100,90);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end

function class:Execution4(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(-250,-120);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end

function class:Execution5(unit)
    local buff =  unit:getTeamUnitCondition():findConditionWithID(-12);
    if not(buff == nil) then
        local conditon = unit:getTeamUnitCondition():findConditionWithID(-12);
        unit:getTeamUnitCondition():removeCondition(conditon);
        local tenbatu = unit:addOrbitSystem("HevnPanish");
        tenbatu:setPosition(-100,0);
    end
    return 1;
end

function class:Execution6(unit)
    local buff =  unit:getTeamUnitCondition():findConditionWithID(-13);
    if not(buff == nil) then
        local conditon = unit:getTeamUnitCondition():findConditionWithID(-13);
        unit:getTeamUnitCondition():removeCondition(conditon);
        local tenbatu = unit:addOrbitSystem("HevnPanish");
        tenbatu:setPosition(100,-80);
    end
    return 1;
end

function class:Execution7(unit)
    local buff =  unit:getTeamUnitCondition():findConditionWithID(-14);
    if not(buff == nil) then
        local conditon = unit:getTeamUnitCondition():findConditionWithID(-14);
        unit:getTeamUnitCondition():removeCondition(conditon);
        local tenbatu = unit:addOrbitSystem("HevnPanish");
        tenbatu:setPosition(300,50);
    end
    return 1;
end

function class:Execution8(unit)
    local buff =  unit:getTeamUnitCondition():findConditionWithID(-15);
    if not(buff == nil) then
        local conditon = unit:getTeamUnitCondition():findConditionWithID(-15);
        unit:getTeamUnitCondition():removeCondition(conditon);
        local tenbatu = unit:addOrbitSystem("HevnPanish");
        tenbatu:setPosition(0,-10);
    end
    return 1;
end

function class:ExecutionEx1(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(250,0);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end

function class:ExecutionEx2(unit)
    local tenbatu = unit:addOrbitSystem("HevnPanish");
    tenbatu:setPosition(-10,0);
    tenbatu:setDamageRateOffset(1/4);
    tenbatu:setBreakRate(1/4);
    return 1;
end


class:publish();

return class;