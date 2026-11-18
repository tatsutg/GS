local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒 志々雄真実", version=1.8, id=108146112});
class:inheritFromUnit("108147112");

class:publish();

return class;