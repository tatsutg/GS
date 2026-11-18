local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒イビルポーラ", version=1.3, id=103816312});
class:inheritFromUnit("103817312");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.spValue = 30
    return 1
end

class:publish();

return class;