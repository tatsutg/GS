local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 覚醒ポーラ", version=1.0, id="idleGame_101246312"});
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
    if event.spineEvent == "shot" then self:shot(event.unit) end
    return 1;
end

function class:shot(unit)
    local shot = unit:IG_addOrbitSystemInsightRotation("2_attack_1_TAMA","empty",1,-150,0,180,0);
    --shot:setDamageRateOffset(3.21)
    return 1;
end


class:publish();

return class;
