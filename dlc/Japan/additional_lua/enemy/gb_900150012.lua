--@additionalEnemy,900150013
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星6_光耀竜フォスラディウス", version=2.5, id="gb_900150012"});
class:inheritFromEnemy("gb_901050012");


function class:setIDs()
    self.summonEnemyID = 900150013  --ブラッディバットのID
end


class:publish();

return class;