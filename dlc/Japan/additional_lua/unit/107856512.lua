local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ディアブロ", version=1.3, id=107856512});
class:inheritFromUnit("107857512");

class:publish();

return class;