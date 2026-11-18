local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヘリオルド", version=2.7, id=104406412});
class:inheritFromUnit("104407412");


class:publish();

return class;