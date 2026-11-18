local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡_10層_HARD_ブルースケルトン", version=2.5, id=2063997});
class:inheritFromEnemy("2063996");

class:publish();

return class;