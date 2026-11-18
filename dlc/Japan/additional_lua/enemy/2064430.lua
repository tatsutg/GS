local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="Q7_ミーナス", version=2.0, id=2064430});
class:inheritFromEnemy("2064445");

class:publish();

return class;