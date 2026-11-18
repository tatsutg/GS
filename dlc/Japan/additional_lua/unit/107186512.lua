local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=107186512});

function class:run (event)
    if event.spineEvent == "setMainDamage" then 
    	event.unit:setDamageRateOffset(0.8) 
    	event.unit:setBreakRate(0.8)
    end
    if event.spineEvent == "addShot" then 
    	local shot = event.unit:addOrbitSystem("shot",1)
    	shot:setDamageRateOffset(0.2)
        shot:setBreakRate(0.2)
        shot:setHitCountMax(1)
        shot:setEndAnimationName("empty")
    end
    return 1;
end

function class:takeSkill(event)
	event.unit:setDamageRateOffset(1) 
    event.unit:setBreakRate(1)
	return 1;
end

function class:takeAttack(event)
    event.unit:setDamageRateOffset(1) 
    event.unit:setBreakRate(1)
    return 1;
end

class:publish();

return class;