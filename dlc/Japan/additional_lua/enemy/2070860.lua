local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="フリーレンコラボ_ユーベル(EX1)", version=2.4, id=2070860});
class:inheritFromEnemy("2070870");

class:publish();

return class;