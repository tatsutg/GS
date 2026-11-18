--@additionalEnemy,900160013,900160014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星6_銀翼魔従ヴァルザンデス", version=2.7, id="gb_900160012"});
class:inheritFromEnemy("gb_901060012");

function class:setIDs()
    self.summonEnemyID1 = 900160013  --メルキオンのID
    self.summonEnemyID2 = 900160014  --竜牙兵のID
end

class:publish();

return class;