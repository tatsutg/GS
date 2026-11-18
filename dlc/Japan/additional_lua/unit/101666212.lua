local class = summoner.Bootstrap.createUnitClass({label="ニース", version=1.3, id=101666212});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
	if event.spineEvent == "shieldOpen" then
	   	for i = 0,7 do
	        local teamUnit = event.unit:getTeam():getTeamUnit(i);
	        if teamUnit ~= nil then       
	            teamUnit:getTeamUnitCondition():addCondition(1016662121,21,-80,5,20)
	        end
	    end
	end
	return 1
end

class:publish();

return class;
