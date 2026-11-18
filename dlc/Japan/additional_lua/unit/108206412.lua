local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_フリーレン", version=1.8, id=108206412});
class:inheritFromUnit("108207412");


class:publish();

return class;