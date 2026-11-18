local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="21章_EX1_霹翠トニトゥルス", version=1.3, id=2105047});
class:inheritFromEnemy("2105050");

class:publish();

return class;