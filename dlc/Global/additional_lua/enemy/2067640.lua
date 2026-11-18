local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="るろ剣_後半_Q9_ラグシェルムファントム", version=2.4, id=2067640});
class:inheritFromEnemy("2067645");

class:publish();

return class;