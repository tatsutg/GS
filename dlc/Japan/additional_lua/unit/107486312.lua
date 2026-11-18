local class = summoner.Bootstrap.createUnitClass({label="恐山アンナ", version=1.9, id=107486312});

function class:run(event)
    if event.spineEvent == "skill2_orbit_B" then
        local orbit = event.unit:addOrbitSystemWithFile("10748ef","skill2_orbit_B")
        orbit:setDamageRateOffset(0)
        orbit:setBreakRate(0)
    end
    if event.spineEvent == "skill2_orbit_F" then
        local orbit = event.unit:addOrbitSystemWithFile("10748ef","skill2_orbit_F")
        orbit:setDamageRateOffset(1)
        orbit:setBreakRate(1)
    end
    return 1
end

class:publish();

return class;