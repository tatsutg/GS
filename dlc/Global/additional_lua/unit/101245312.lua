local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="星5ポーラ", version=2.6, id=101245312});
class:inheritFromUnit("101246312");

class:publish();

return class;
