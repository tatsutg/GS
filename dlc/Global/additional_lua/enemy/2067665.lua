local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="斎藤 一(EX2)", version=2.4, id=2067665});
class:inheritFromEnemy("2067660");

class:publish();

return class;