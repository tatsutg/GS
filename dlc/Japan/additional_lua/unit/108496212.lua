local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="魔血クロエ(覚醒)", version=1.8, id=108496212});
class:inheritFromUnit("108497212");

class:publish();

return class;
