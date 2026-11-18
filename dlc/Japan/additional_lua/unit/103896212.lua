local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴァレリー", version=1.3, id=103896212});
class:inheritFromUnit("103897212");

class:publish();
return class;