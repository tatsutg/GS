local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="_EX1_被験体-β-3", version=2.8, id=2081760});
class:inheritFromEnemy("2081770");


class:publish();

return class;