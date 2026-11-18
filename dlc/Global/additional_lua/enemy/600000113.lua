local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_炎玉精イグニス（弱）", version=2.0, id=600000113});
class:inheritFromEnemy("600000114");



class:publish();

return class;