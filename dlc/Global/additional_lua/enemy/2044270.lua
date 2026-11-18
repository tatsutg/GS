local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX_妖狐 憂月 (炎)", version=1.3, id=2044270});
class:inheritFromEnemy("2044275");

class:publish();

return class;