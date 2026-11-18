local class = summoner.Bootstrap.createUnitClass({label="闇ハルト", version=1.9, id=103286512});

function class:start(event)
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    if event.unit:getFantasyEvolutionType() == 5 then
        event.unit:getPhantomBulletSkill():setDamageRate(1500);
    end
    return 1
end

function class:run(event)
    if event.spineEvent == "shot" then
        local orbit = event.unit:addOrbitSystem("shot",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
        orbit:setHitCountMax(1)
        orbit:setEndAnimationName("skill2_hit")
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
    if event.index == 2 then
        event.unit:setDamageRateOffset(0.25)
        event.unit:setBreakRate(0.25)
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill3_PB")
        event.unit:setNextAnimationEffectName("2-skill3_PB")
    end
    return 1
end


class:publish();

return class;