local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着バゼット", version=1.3, id=108006212});
class:inheritFromUnit("108007212");

class:publish();

return class;