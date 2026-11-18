local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="影実_Q10_黒ヴァルザンデス", version=2.0, id=2062245});
class:inheritFromEnemy("2062240");


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end


class:publish();

return class;