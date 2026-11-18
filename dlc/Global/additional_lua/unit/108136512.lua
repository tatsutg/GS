local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒 斎藤一", version=1.8, id=108136512});
class:inheritFromUnit("108137512");

class:publish();

return class;