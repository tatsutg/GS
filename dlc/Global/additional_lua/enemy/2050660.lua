local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="地獄楽_EX1_キサラギ", version=1.3, id=2050660});
class:inheritFromEnemy("2050665");


class:publish();

return class;