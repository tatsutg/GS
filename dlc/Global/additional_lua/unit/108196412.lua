local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_インデックス", version=1.8, id=108196412});
class:inheritFromUnit("108197412");


class:publish();

return class;