local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒バレンタインシスティーナ", version=2.0, id=103866212});
class:inheritFromUnit("103867212");

class:publish();

return class;