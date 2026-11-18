local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超十二代目ミズキ_覚醒前", version=2.6, id=104266212});
class:inheritFromUnit("104267212");

class:publish();

return class;