--@additionalEnemy,900140012, 900140013, 900140014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星6_ツァイバーZ", version=2.0, id="gb_900140011"});
class:inheritFromEnemy("gb_901040011");


function class:setIDs()
    self.pileEnemyID = 900140012
    self.summonEnemyID1 = 900140013  --SX-602型LimitedのID
    self.summonEnemyID2 = 900140014  --グランガロードのID
end


class:publish();

return class;