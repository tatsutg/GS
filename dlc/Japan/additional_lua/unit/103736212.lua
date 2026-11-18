local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒水着フェン", version=1.3, id=103736212});
class:inheritFromUnit("103737212");

class:publish();

return class;