local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒フィリル", version=2.6, id=104216212});
class:inheritFromUnit("104217212");


class:publish();

return class;