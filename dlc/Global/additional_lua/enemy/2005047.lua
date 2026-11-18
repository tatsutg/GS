local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_絶氷竜アエルグラキエス", version=1.3, id=2005047});
class:inheritFromEnemy("2005050")

class:publish();

return class;