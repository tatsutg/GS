local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ラビッツ4_EX1_被験体φ－２", version=2.5, id=2075162});
class:inheritFromEnemy("2075181");


class:publish();

return class;