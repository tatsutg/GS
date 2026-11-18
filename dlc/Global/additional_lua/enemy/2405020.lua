local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_ルアーナ", version=1.3, id=2405020});
class:inheritFromEnemy("2405021");


class:publish();

return class;