local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒エレノア", version=2.0, id=103886312});
class:inheritFromUnit("103887312");

class:publish();

return class;