local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_ハロウィンヴァレリー", version=1.3, id=103786212});
class:inheritFromUnit("103787212");

class:publish();

return class;