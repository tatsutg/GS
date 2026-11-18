local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒超レイアス", version=2.0, id=104246412});
class:inheritFromUnit("104247412");

class:publish();

return class;