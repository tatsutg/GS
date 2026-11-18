local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=102626212});

function class:takeSkill(event)
	if event.index ~= 3 then
		return 1;
	end
	local countCond = event.unit:getTeamUnitCondition():findConditionWithID(157);
	 
	 if countCond ~= nil then
	 	if countCond:getValue2() == 0 then
	 		event.unit:getTeamUnitCondition():removeCondition(countCond);
	 	else
	 		countCond:setValue2(0);
	 	end
	 end
	return 1;
end

class:publish();

return class;