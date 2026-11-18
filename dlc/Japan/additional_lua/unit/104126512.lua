local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒 ヒューマ", version=1.8, id=104126512});
class:inheritFromUnit("104127512");

class:publish();

return class;