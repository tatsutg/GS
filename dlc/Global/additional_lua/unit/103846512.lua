local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_虚構魔術士ハルト", version=2.0, id=103846512});
class:inheritFromUnit("103847512");

class:publish();

return class;