local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="Q9_ミーナス", version=2.0, id=2064440});
class:inheritFromEnemy("2064445");

class:publish();

return class;