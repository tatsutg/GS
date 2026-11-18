local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_水着イリス", version=1.3, id=2050460});
class:inheritFromEnemy("2050465");


class:publish();

return class;