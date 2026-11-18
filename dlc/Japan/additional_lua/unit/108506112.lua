local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒衛宮士郎（英霊エミヤver）", version=2.8, id=108506112});
class:inheritFromUnit("108507112");



class:publish();

return class;