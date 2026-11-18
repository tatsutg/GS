local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒超レオーネ", version=2.5, id=104176412});
class:inheritFromUnit("104177412");


class:publish();

return class;