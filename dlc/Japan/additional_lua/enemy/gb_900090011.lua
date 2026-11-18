--@additionalEnemy,900090012, 900090013, 900090014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_ツァイバーZ", version=2.0, id="gb_900090011"});
class:inheritFromEnemy("gb_901040011");


function class:setIDs()
    self.pileEnemyID = 900090012
    self.summonEnemyID1 = 900090013  --SX-602型LimitedのID
    self.summonEnemyID2 = 900090014  --グランガロードのID
end


class:publish();

return class;