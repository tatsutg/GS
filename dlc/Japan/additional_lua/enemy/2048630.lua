local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ中編_Q7_キングミキュオン", version=1.3, id=2048630});
class:inheritFromEnemy("2048600");


class:publish();

return class;