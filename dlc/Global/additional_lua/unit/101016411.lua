local class = summoner.Bootstrap.createUnitClass({label="覚醒レイアス", version=2.2, id=101016411});

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end


function class:takeTransIn(event)
    self.TIME = 0
    if self:findWeapon(event.unit,50266300) then
        if not self:checkParametor(event.unit,"addTime") then
            self.TIME = event.unit:getTransTime() + 30
            event.unit:setParameter("addTime","TRUE");
            event.unit:setParameter("transTime",self.TIME);
        else
            self.TIME = tonumber(event.unit:getParameter("transTime"))
        end
        event.unit:setTransTime(self.TIME)
        event.unit:addSPWithPvpCorrection(100);
    end
    return 1
end

function class:takeSkill(event)
    if event.unit:getIsChangeUnit() then
        event.unit:setCutinVoice2("VOICE_FULLARTS_CUTIN_B_XP")
    else
        event.unit:setCutinVoice2("VOICE_FULLARTS_CUTIN_B")
    end
    return 1
end

class:publish();

return class;
