local class = summoner.Bootstrap.createUnitClass({label="カティロ", version=1.9, id=101596312});

function class:run(event)
    if event.spineEvent == "skill3orbit" then
        local orbit = event.unit:addOrbitSystemWithFile("10159ef","skill3_stone2")
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    return 1
end

function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index == 3 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end
    return 1
end

class:publish();

return class;