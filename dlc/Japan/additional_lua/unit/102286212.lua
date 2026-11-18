local class = summoner.Bootstrap.createUnitClass({label="ろっず", version=1.3, id=102286212});

class.BUFF_VALUE = 10;

function class:start(event)
    self.buffCompleat = false;
	return 1;
end

function class:update(event)
    if self.buffCompleat then
        return 1;
    end
    if event.unit:getTeamUnitCondition():findConditionWithID(102281) ~= nil then
        return 1;
    end
    if event.unit:getLevel() >= 90 then
        local count = -1;--マスターからかかる分を引いておく
        for i = 0,7 do
            local teamUnit = event.unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then  
                if teamUnit:getSexuality() == 2 then
                    count = count + 1;
                end
            end
        end
        if count > 0 then
            event.unit:getTeamUnitCondition():addCondition(102281,2,self.BUFF_VALUE * count,999999,0);
            event.unit:getTeamUnitCondition():addCondition(102282,13,self.BUFF_VALUE * count,999999,0);
            event.unit:getTeamUnitCondition():addCondition(102283,15,self.BUFF_VALUE * count,999999,0);
        end
        self.buffCompleat = true;
    end
    
    return 1;
end

class:publish();

return class;