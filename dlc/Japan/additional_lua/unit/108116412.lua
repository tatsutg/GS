local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒緋村剣心", version=2.0, id=108116412});
class:inheritFromUnit("108117412");


class:publish();

return class;