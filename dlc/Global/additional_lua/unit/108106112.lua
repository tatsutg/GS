local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒シズ", version=1.3, id=108106112});
class:inheritFromUnit("108107112");

class:publish();

return class;