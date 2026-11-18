local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_弱_キングレキュオン", version=1.3, id=600000111});
class:inheritFromEnemy("600000112");

class:publish();

return class;