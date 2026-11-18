local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame ボス メリア", version=1.0, id="idleGame_500411593"});
class:inherit("idleGameBase")
local json = summoner.Json;

-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack2")
    event.unit:setNextAnimationEffectName("1-attack2")
    return 1;
end

class:publish();

return class;
