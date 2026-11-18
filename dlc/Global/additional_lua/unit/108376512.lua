local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒リムル（イースターver）", version=2.6, id=108376512});
class:inheritFromUnit("108377512");

class:publish();

return class;