local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="BRS_EX2_CODE XTF:ERASER", version=1.3, id=2040965});
class:inheritFromEnemy("2040960");

class:publish();

return class;