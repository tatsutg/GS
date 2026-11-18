local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="26章_EX1_覇罪皇ギアベール", version=1.3, id=2605020});
class:inheritFromEnemy("2605021");


class:publish();

return class;