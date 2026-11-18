--@additionalEnemy,900540012, 900540013, 900540014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_ツァイバーZ", version=2.0, id="gb_900540011"});
class:inheritFromEnemy("gb_901040011");


function class:setIDs()
    self.pileEnemyID = 900540012
    self.summonEnemyID1 = 900540013  --SX-602型LimitedのID
    self.summonEnemyID2 = 900540014  --グランガロードのID
end


class:publish();

return class;