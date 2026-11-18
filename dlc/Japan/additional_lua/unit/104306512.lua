local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒超シモン", version=2.8, id=104306512});
class:inheritFromUnit("104307512");



class:publish();

return class;