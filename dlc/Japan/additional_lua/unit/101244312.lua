local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="星4ポーラ", version=2.6, id=101244312});
class:inheritFromUnit("101246312");

function class:setAnimationName()
    self.animationName = "1_attack_1_TAMA";
end

class:publish();

return class;