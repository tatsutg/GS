local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超神具／ドゥーラ2", version=1.3, id=2054703});
class:inheritFromEnemy("2054702");

class:publish();

return class;