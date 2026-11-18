local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_クォ・ヴァディス(白亜の巨神)", version=1.3, id=2205020});
class:inheritFromEnemy("2205021")

class:publish();

return class;