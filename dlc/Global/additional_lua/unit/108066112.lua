local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒デルタ", version=1.3, id=108066112});
class:inheritFromUnit("108067112");

class:publish();

return class;