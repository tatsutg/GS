local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="クロエ", version=2.6, id=103053511});
class:inheritFromUnit("103056511");

class:publish();

return class;
