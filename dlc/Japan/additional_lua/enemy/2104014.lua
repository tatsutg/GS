local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="21章クエスト_天魔帥ゼ＝レムナ", version=1.3, id=2104014});
class:inheritFromEnemy("2104015");

class:publish();

return class;