local class = summoner.Bootstrap.createUnitClass({label="巨大エミー", version=1.3, id=103245512});

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.SP_VALUE = 100
    if  self:findWeapon(event.unit,50265900) then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active and not megast.Battle:getInstance():isPvp() then
            if not self:checkParametor(event.unit,"startDash") then
                self:startDash(event.unit);
                event.unit:setParameter("startDash","TRUE");
            end
        end
    end
    return 1
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end

function class:startDash(unit)
    unit:addSPWithPvpCorrection(self.SP_VALUE);
end


function class:run(event)
    if event.spineEvent == "endAnimation" then return 1 end
    
    if string.gmatch(event.spineEvent,"shot") then
        --local orbit = event.unit:addOrbitSystem(event.spineEvent)
        ---event.unitがオービットの場合は回避
        if event.unit:getParentTeamUnit() == nil then
            local orbit =event.unit:addOrbitSystemInsight(event.spineEvent,"hit1",1,0,0,0,0);
            orbit:setDamageRateOffset(1/8*2.2)
            orbit:setBreakRate(1/8)
        end
    end
    return 1
end

class:publish();

return class;
