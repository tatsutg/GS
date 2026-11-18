local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ブルージャケット_EX1_カナリア", version=1.3, id=2051860});
class:inheritFromEnemy("2051865");


class:publish();

return class;