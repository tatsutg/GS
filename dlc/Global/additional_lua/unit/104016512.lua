local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_水着シーリア", version=1.3, id=104016512});
class:inheritFromUnit("104017512");

class:publish();

return class;