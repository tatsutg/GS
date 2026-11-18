local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒魔王リムル（和装ver）", version=1.3, id=108076512});
class:inheritFromUnit("108077512");

class:publish();

return class;