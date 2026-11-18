local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒相楽左之助", version=2.0, id=108126212});
class:inheritFromUnit("108127212");


class:publish();

return class;