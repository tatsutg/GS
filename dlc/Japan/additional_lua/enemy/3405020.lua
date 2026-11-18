local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="34章_クロエ(EX1)", version=2.4, id=3405020});
class:inheritFromEnemy("3405023");

class:publish();

return class;