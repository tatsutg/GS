local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒モモン", version=1.3, id=107906512});
class:inheritFromUnit("107907512");

class:publish();

return class;