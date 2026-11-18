local class = summoner.Bootstrap.createUnitClass({label="マリカ", version=1.3, id=103196112})

function class:run(event)
    if event.spineEvent == "missile" then
        local orbit = event.unit:addOrbitSystemWithFile("10319ef","missile")
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    return 1
end

function class:takeSkill(event)
    if event.index == 3 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end
    return 1
end

class:publish();

return class;