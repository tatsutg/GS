local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="25章フォンギオンNORMAL", version=1.3, id=2504003});
class:inheritFromEnemy("2504013");

function class:defaultParameter()
    self.defaultRate = 0.3
end

class:publish();

return class;