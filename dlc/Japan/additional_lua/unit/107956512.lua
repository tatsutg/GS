local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒蟇郡苛", version=2.6, id=107956512});
class:inheritFromUnit("107957512");

class:publish();

return class;