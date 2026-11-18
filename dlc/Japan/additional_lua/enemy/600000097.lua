local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_グロイツ", version=1.3, id=600000097});
class:inheritFromEnemy("600000098");


class:publish();

return class;