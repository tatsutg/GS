--@additionalItem, 160052505
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="水霧の遺跡_19層_フォンギオン", version=2.8, id=2004557});
class:inheritFromEnemy("2004556");


class:publish();

return class;