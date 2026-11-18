local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒オーヴェル・D・クランベルジュ", version=2.0, id=104066412});
class:inheritFromUnit("104067412");

class:publish();

return class;