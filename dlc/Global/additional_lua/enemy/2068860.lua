local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ワンパンマン_ジェノス(EX1)", version=2.4, id=2068860});
class:inheritFromEnemy("2068865");

class:publish();

return class;