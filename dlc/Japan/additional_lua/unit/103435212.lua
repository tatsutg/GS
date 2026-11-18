local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="うそつきセリア", version=1.3, id=103435212});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "card1" then
        local orbit = event.unit:addOrbitSystem("skill1_orbit1",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
    end

    if event.spineEvent == "card2" then
        local orbit = event.unit:addOrbitSystem("skill1_orbit2",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
    end

    if event.spineEvent == "card3" then
        local orbit = event.unit:addOrbitSystem("skill1_orbit3",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
    end

    if event.spineEvent == "card4" then
        local orbit = event.unit:addOrbitSystem("skill1_orbit4",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
    end

    if event.spineEvent == "iceSword" then
        local orbit = event.unit:addOrbitSystem("skill3_orbit",0)
        orbit:setDamageRateOffset(0.8)
        orbit:setBreakRate(0.8)
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

    if event.index == 3 then
        event.unit:setDamageRateOffset(0.2)
        event.unit:setBreakRate(0.2)
    end
    return 1
end


class:publish();

return class;