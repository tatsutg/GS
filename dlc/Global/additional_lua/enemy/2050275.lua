local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX極_ミキュオン", version=1.3, id=2050275});
class:inheritFromEnemy("2050285");


class:publish();

return class;