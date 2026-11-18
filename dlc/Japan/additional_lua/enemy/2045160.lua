local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="オバロ前半_EX1_神焔竜デグルマグナ", version=1.3, id=2045160});
class:inheritFromEnemy("2045165");


class:publish();

return class;