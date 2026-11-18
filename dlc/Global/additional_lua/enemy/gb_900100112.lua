--@additionalEnemy,900100113
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_光耀竜フォスラディウス", version=2.5, id="gb_900100112"});
class:inheritFromEnemy("gb_901050012");


function class:setIDs()
    self.summonEnemyID = 900100113  --ブラッディバットのID
end


class:publish();

return class;