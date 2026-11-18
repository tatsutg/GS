local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 覚醒アリステラ", version=1.0, id="idleGame_101296212"});
class:inherit("idleGameBase")
local json = summoner.Json;

-- event {unit, instance }
--SpineがAddChildされた直後に呼ばれる
function class:start(event)
    self.gameUnit = event.unit;
end

--event {unit,index}
function class:run(event)
    if event.spineEvent == "attackShot" then self:attackShot(event.unit) end
    return 1;
end

-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack1");
    return 1;
end

function class:attackShot(unit)
    local attack1 = unit:IG_addOrbitSystemInsightRotation("2--AttackShot","emp",1,-50,100,180,0);
    return 1;
end


class:publish();

return class;
