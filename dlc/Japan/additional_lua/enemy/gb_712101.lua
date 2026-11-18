local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB暗黒魔導オグナード", version=2.5, id="gb_712101"});
class:inheritFromEnemy("gb_103401");

class:publish();

return class;
