local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グリムステラ2_EX1_神焔竜デグルマグナ", version=1.3, id=2046960});
class:inheritFromEnemy("2046965");


class:publish();

return class;