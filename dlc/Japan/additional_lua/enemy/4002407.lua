local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超新星級/壊魂滅神ゼノン(NORMAL)", version=2.7, id=4002407});
class:inheritFromEnemy("4002408");

class:publish();

return class;