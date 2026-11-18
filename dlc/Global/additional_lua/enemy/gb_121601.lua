local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="エリア１_チュートリアル_ベルギラス", version=2.0, id="gb_121601"});
class:inheritFromEnemy("gb_102601");

class.TEXT = summoner.Text:fetchByEnemyID("gb_102601")

class:publish();

return class;