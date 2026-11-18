local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒_水篠 旬", version=2.6, id=108396512});
class:inheritFromUnit("108397512");


class:publish();

return class;