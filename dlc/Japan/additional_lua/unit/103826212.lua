local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒超ロイ", version=2.0, id=103826212});
class:inheritFromUnit("103827212");

class:publish();

return class;