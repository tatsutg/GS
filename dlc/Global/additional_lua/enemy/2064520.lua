local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族遺跡 ヴィラカーズnormal", version=1.3, id=2064520});
class:inheritFromEnemy("2064525");

class:publish();

return class;