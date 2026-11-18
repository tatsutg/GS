local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="オバロ２前半_Q9_アルベド", version=1.3, id=2056440});
class:inheritFromEnemy("2056445");


class:publish();

return class;