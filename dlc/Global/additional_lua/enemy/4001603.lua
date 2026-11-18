local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="輪廻の神殿／キングピキュオン", version=1.3, id=4001603});

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    event.unit:setDeadDropSp(100)
    return 1
end

class:publish();

return class;