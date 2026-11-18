local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="原典の魔女セリア(EX1)", version=2.4, id=2068360});
class:inheritFromEnemy("2068370");

class:publish();

return class;