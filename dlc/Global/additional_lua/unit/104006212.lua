local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着ミラ", version=1.3, id=104006212});
class:inheritFromUnit("104007212");

class:publish();

return class;