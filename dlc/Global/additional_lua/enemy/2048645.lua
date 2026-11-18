local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ中編_Q10_ラグシェルム・絶", version=1.3, id=2048645});
class:inheritFromEnemy("2048640");


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end


class:publish();

return class;