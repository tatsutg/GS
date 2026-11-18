--@additionalEnemy,900250013
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星9_光耀竜フォスラディウス", version=2.5, id="gb_900250012"});
class:inheritFromEnemy("gb_901050012");


function class:setIDs()
    self.summonEnemyID = 900250013  --ブラッディバットのID
end


class:publish();

return class;