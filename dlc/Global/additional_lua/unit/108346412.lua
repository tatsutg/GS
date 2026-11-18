local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒霧雨魔理沙", version=2.6, id=108346412});
class:inheritFromUnit("108347412");

class:publish();

return class;