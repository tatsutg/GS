--@additionalEnemy,900110113,900110114
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_銀翼魔従ヴァルザンデス", version=2.7, id="gb_900110112"});
class:inheritFromEnemy("gb_901060012");

function class:setIDs()
    self.summonEnemyID1 = 900110113  --メルキオンのID
    self.summonEnemyID2 = 900110114  --竜牙兵のID
end

class:publish();

return class;