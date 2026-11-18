local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="アルカナ", version=2.7, id=103125512});
class:inheritFromUnit("103126512");

class:publish();

return class;