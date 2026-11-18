local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_バレンタインリザ", version=1.3, id=103856312});
class:inheritFromUnit("103857312");

class:publish();

return class;