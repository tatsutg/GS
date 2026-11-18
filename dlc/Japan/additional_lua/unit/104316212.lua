local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒アズライト", version=2.8, id=104316212});
class:inheritFromUnit("104317212");


class:publish();

return class;