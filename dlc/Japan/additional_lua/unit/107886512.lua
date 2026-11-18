local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ペンシルゴン", version=1.3, id=107886512});
class:inheritFromUnit("107887512");

class:publish();

return class;