local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒西行寺幽々子", version=2.6, id=108366512});
class:inheritFromUnit("108367512");

class:publish();

return class;