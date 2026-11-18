local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒デミウルゴス", version=1.3, id=107916112});
class:inheritFromUnit("107917112");


class:publish();

return class;