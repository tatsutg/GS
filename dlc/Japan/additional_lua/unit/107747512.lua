local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒_美遊", version=1.3, id=107747512});


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "orbit_SK5" then
        local orbit = event.unit:addOrbitSystem("orbit_SK5",0)
        orbit:setDamageRateOffset(0.1)
        orbit:setBreakRate(0.1)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if event.index == 5 then
        event.unit:setDamageRateOffset(0.9)
        event.unit:setBreakRate(0.9)
    end
    return 1
end


class:publish();

return class;