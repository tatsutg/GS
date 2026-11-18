local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="星5ミラ", version=2.6, id=101045111});
class:inheritFromUnit("101046111");

class:publish();

return class;