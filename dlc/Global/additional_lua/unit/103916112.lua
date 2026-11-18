local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒アズエル", version=1.3, id=103916112});
class:inheritFromUnit("103917112");

function class:setRP(unit)
    unit:setRPEnable(false);
    return 1
end

class:publish();

return class;