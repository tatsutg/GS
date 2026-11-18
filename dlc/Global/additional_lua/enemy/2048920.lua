local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ後編_Q5_闇玉精プルートゥ", version=1.3, id=2048920});
class:inheritFromEnemy("2048925");

class:publish();

return class;