local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超襲来ハクロウ_真EX極_シノビ_ボス", version=1.3, id=2043420});
class:inheritFromEnemy("2043416");

class:publish();

return class;