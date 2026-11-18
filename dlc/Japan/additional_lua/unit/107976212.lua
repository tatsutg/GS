local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着イリヤ", version=1.3, id=107976212});
class:inheritFromUnit("107977212");


class:publish();

return class;