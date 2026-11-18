local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着リヴィエラ", version=1.3, id=103746112});
class:inheritFromUnit("103747112");

class:publish();

return class;