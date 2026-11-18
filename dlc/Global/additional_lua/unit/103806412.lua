local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒超皇帝", version=1.8, id=103806412});
class:inheritFromUnit("103807412");

class:publish();

return class;