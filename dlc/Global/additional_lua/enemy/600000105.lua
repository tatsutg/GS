local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_ダークコロック（弱）", version=1.3, id=600000105});
class:inheritFromEnemy("600000106");


class:publish();

return class;