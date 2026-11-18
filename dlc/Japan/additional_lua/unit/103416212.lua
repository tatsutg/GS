local class = summoner.Bootstrap.createUnitClass({label="覚醒プリシラ-Is", version=1.9, id=103416212});

function class:start(event)
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    return 1
end
---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 4 then
        event.unit:setNextAnimationName("skill3_PB")
        event.unit:setNextAnimationEffectName("2-skill3_PB")
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "Library_PB_Hit" then
        local orbit = event.unit:addOrbitSystem("PB_Hit",0)
        local skill = orbit:getActiveBattleSkill();
        if skill ~= nil then
            if event.unit:getFantasyEvolutionType() == 5 then
                event.unit:getPhantomBulletSkill():setDamageRate(2000)
            end
        end
    end
    return 1;
end


class:publish();

return class;