local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒水着イリス", version=1.3, id=103726112});
class:inheritFromUnit("103727112");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.burstPointMax = 200
    return 1
end

class:publish();

return class;