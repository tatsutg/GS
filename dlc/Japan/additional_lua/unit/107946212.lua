local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒犬牟田宝火", version=1.3, id=107946212});
class:inheritFromUnit("107947212");


class:publish();

return class;