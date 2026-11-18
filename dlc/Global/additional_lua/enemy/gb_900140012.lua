local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星6_蒼騎士用設置兵器(グラーシーザ)", version=2.0, id=900140012});
class:inheritFromEnemy("901040012");


class:publish();

return class;