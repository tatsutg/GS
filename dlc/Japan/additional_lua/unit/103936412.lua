local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ユナ", version=1.8, id=103936412});
class:inheritFromUnit("103937412");


class:publish();

return class;