local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ラーク", version=1.3, id=103876112});
class:inheritFromUnit("103877112");


class:publish();

return class;