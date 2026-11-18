local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒アルファ", version=1.3, id=108046412});
class:inheritFromUnit("108047412");

class:publish();

return class;