local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="決選投票イベント ノエル(EX1)", version=2.4, id=2069260});
class:inheritFromEnemy("2069270");

class:publish();

return class;