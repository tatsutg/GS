--@additionalEnemy,900260013,900260014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星9_銀翼魔従ヴァルザンデス", version=2.7, id="gb_900260012"});
class:inheritFromEnemy("gb_901060012");

function class:setIDs()
    self.summonEnemyID1 = 900260013  --メルキオンのID
    self.summonEnemyID2 = 900260014  --竜牙兵のID
end

class:publish();

return class;