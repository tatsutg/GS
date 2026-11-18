local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒オイカッツォ", version=1.3, id=107896112});
class:inheritFromUnit("107897112");


class:publish();

return class;