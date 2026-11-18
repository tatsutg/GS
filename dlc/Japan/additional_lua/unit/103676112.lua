local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒バレンタインプリシラ", version=1.3, id=103676112});
class:inheritFromUnit("103677112");

class:publish();

return class;