local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="オバロ２後半_Q9_葬魂神オルデウス", version=1.3, id=2056540});
class:inheritFromEnemy("2056545");

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    event.unit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
end


class:publish();

return class;