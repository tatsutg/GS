local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ネアス", version=2.6, id=104366212});
class:inheritFromUnit("104367212");

class:publish();

return class;
