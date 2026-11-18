local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒エレンス", version=2.0, id=104096312});
class:inheritFromUnit("104097312");

class:publish();

return class;