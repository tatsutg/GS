local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_水着フェン", version=1.3, id=2050260});
class:inheritFromEnemy("2050265");


class:publish();

return class;