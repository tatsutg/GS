local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_熾紅フロガスピサ", version=2.0, id="gb_900050011"});
class:inheritFromEnemy("gb_901000011");


class:publish();

return class;