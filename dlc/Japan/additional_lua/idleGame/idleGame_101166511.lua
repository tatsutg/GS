local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 覚醒レム", version=1.0, id="idleGame_101166511"});
class:inherit("idleGameBase")
local json = summoner.Json;

-- event {unit, instance }
--SpineがAddChildされた直後に呼ばれる
function class:start(event)
    self.gameUnit = event.unit;
end

-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack1");
    return 1;
end

--event {unit,index}
function class:run(event)
    if event.spineEvent == "attack2" then self:attack2(event.unit) end
    return 1;
end

function class:attack2(unit)
    unit:IG_addOrbitSystemInsightRotation("attack1Shot2","attack1Hit2",1,0,217,180,0);
    return 1;
end


class:publish();

return class;
