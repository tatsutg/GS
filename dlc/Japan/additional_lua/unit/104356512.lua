local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒オニキス", version=2.7, id=104356512});
class:inheritFromUnit("104357512");


class:publish();

return class;