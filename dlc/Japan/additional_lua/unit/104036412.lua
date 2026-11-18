local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ミゼット", version=2.3, id=104036412});
class:inheritFromUnit("104037412");

class:publish();

return class;