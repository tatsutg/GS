local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒ジェイ", version=1.3, id=103706212});
class:inheritFromUnit("103707212");

class:publish();

return class;