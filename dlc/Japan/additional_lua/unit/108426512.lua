local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒イグリット", version=2.6, id=108426512});
class:inheritFromUnit("108427512");

class:publish();

return class;