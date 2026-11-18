local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_光玉精ウィルクス", version=1.3, id=600000090});
class:inheritFromEnemy("600000091");


class:publish();

return class;