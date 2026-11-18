local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_コスモ", version=1.3, id=2041760});
class:inheritFromEnemy(2041765)

class:publish();

return class;