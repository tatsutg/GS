local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ前編_クロエ（魔血フォーム）", version=1.2, id=2083045});
class:inheritFromEnemy("2083015");
class:publish();
return class;
