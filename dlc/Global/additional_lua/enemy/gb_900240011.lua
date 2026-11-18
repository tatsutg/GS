--@additionalEnemy,900240012, 900240013, 900240014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星9_ツァイバーZ", version=2.0, id="gb_900240011"});
class:inheritFromEnemy("gb_901040011");


function class:setIDs()
    self.pileEnemyID = 900240012
    self.summonEnemyID1 = 900240013  --SX-602型LimitedのID
    self.summonEnemyID2 = 900240014  --グランガロードのID
end


class:publish();

return class;