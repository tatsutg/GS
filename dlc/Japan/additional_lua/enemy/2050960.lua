local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="地獄楽_EX1_オンファン（バイロン）", version=1.3, id=2050960});
class:inheritFromEnemy("2050965");


class:publish();

return class;