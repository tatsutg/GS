local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="フリーレンコラボ_シュタルク", version=1.8, id=108226112});
class:inheritFromUnit("108227112");

class:publish();

return class;