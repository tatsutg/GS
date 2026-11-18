local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒マーレット", version=2.0, id=103836412});
class:inheritFromUnit("103837412");

class:publish();

return class;