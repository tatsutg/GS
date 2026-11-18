local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="水着イベ_EX1_水着ロゼッタ", version=1.3, id=2051560});
class:inheritFromEnemy("2051565");


class:publish();

return class;