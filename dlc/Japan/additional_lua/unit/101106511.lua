local class = summoner.Bootstrap.createUnitClass({label="ニーア", version=1.3, id=101106511});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    local rate = 1 / 7
    if event.spineEvent == "2orbitSnake1_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake2_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake3_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake4_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake5_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake6_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
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
        event.unit:setDamageRateOffset(1/7)
        event.unit:setBreakRate(1/7)
    end
    return 1
end



class:publish();

return class;