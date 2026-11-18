local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ２中編_Q2 キングピキュオン(どでか)", version=1.3, id=2059705});
class:inheritFromEnemy("2059745");


class:publish();

return class;