local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒シャドウ", version=1.3, id=108036512});
class:inheritFromUnit("108037512");

class:publish();

return class;