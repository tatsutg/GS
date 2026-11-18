local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame モルドーラ", version=1.0, id="idleGame_500951313"});
class:inherit("idleGameBase")
local json = summoner.Json;

function class:start(event)
    event.unit:getSkeleton():setScaleX(-1);
end

class:publish();

return class;
