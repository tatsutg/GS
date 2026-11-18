local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着クロエ", version=1.3, id=107996412});
class:inheritFromUnit("107997412");


class:publish();

return class;