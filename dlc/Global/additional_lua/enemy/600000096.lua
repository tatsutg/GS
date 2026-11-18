--@additionalEnemy,600000046,600000047,600000048,600000049,600000050,600000051,600000052
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイドカボシェルム", version=1.3, id=600000096});
class:inheritFromEnemy("600000045");


class:publish();

return class;
