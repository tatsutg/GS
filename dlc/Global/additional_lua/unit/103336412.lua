local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒ルアーナ", version=1.3, id=103336412});
class:inheritFromUnit("103337412");

class:publish();

return class;