local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_コロック(弱)", version=1.3, id=2056101});
class:inheritFromEnemy("2056102");


class:publish();

return class;