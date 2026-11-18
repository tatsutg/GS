local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着桜", version=2.0, id=108026512});
class:inheritFromUnit("108027512");

class:publish();

return class;