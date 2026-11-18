local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="アルシェ", version=1.3, id=101735412});
class:inheritFromUnit("101736412");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.hpReduceValue = -20
    return 1
end


class:publish();

return class;