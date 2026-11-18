local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_堕天神獣 β－３(被験体β－３)", version=1.3, id=600000086});
class:inheritFromEnemy("600000087");

class:publish();

return class;