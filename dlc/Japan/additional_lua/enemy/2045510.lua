local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="オバロ後半_Q3_魔獄竜マヴロハロス", version=1.3, id=2045560});
class:inheritFromEnemy("2045565");

class:publish();

return class;