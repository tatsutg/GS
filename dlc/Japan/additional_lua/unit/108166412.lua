local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_御坂美琴", version=1.8, id=108166412});
class:inheritFromUnit("108167412");


class:publish();

return class;