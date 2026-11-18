--@additionalEnemy,2081865
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="EX1_竜牙兵", version=2.8, id=2081860});
class:inheritFromEnemy("2081870");


function class:setSummonIDs()
    self.summonID = 2081865;
end


class:publish();

return class;
