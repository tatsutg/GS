local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 星4オグナード", version=1.0, id="idleGame_100404511"});
class:inherit("idleGameBase")
-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack1");
    return 1;
end

-- event {unit,index}
function class:run(event)
    if event.spineEvent == "swordAttack" then
        local orbit = event.unit:IG_addOrbitSystem(event.unit:getEvolutionStage().."attack1sword", 1)
        orbit:setHitCountMax(1)
        orbit:setEndAnimationName(event.unit:getEvolutionStage().."attack1explode")
        local posX = event.unit:getPositionX()
        local posY = event.unit:getPositionY()
        orbit:setPosition(posX, posY)
    end
    return 1;
end

class:publish();
return class;
