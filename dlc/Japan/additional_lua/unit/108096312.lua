local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴェルドラ", version=1.3, id=108096312});
class:inheritFromUnit("108097312");

class:publish();

return class;