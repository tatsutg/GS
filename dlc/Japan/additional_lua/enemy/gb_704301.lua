local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB雷弓士ファル", version=2.5, id="gb_704301"});
class:inheritFromEnemy("gb_501301");

class:publish();

return class;
