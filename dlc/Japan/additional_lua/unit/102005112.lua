local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ジェラルド", version=2.6, id=102005112});
class:inheritFromUnit("102006112");

class:publish();
return class;