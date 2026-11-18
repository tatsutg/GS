local class = summoner.Bootstrap.createUnitClass({label="覚醒カイト", version=1.9, id=101626312});

function class:start(event)
    return 1
end

function class:run(event)
    if event.spineEvent == "plant1" then
        local orbit = event.unit:addOrbitSystem("plant_skill3_1",0)
        orbit:setDamageRateOffset(0.1)
        orbit:setBreakRate(0.1)
    end
    if event.spineEvent == "plant2" then
        local orbit = event.unit:addOrbitSystem("plant_skill3_2",0)
        orbit:setDamageRateOffset(0.1)
        orbit:setBreakRate(0.1)
    end
    if event.spineEvent == "plant3" then
        local orbit = event.unit:addOrbitSystem("plant_skill3_3",0)
        orbit:setDamageRateOffset(0.1)
        orbit:setBreakRate(0.1)
    end
    if event.spineEvent == "plant4" then
        local orbit = event.unit:addOrbitSystem("plant_skill3_4",0)
        orbit:setDamageRateOffset(0.1)
        orbit:setBreakRate(0.1)
    end
    if event.spineEvent == "plant5" then
        local orbit = event.unit:addOrbitSystem("plant_skill3_last",0)
        orbit:setDamageRateOffset(0.6)
        orbit:setBreakRate(0.6)
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
    return 1
end


class:publish();

return class;