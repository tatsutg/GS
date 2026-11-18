local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ベータ", version=1.3, id=108056212});
class:inheritFromUnit("108057212");


class:publish();

return class;