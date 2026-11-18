local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒博麗霊夢", version=2.6, id=108336112});
class:inheritFromUnit("108337112");

class:publish();

return class;