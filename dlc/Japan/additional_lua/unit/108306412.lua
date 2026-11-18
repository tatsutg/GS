local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒巴マミ", version=2.6, id=108306412});
class:inheritFromUnit("108307412");


class:publish();

return class;