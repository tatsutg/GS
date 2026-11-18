local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ルド", version=2.8, id=108516112});
class:inheritFromUnit("108517112");
class.AMULET_FILE = "108516112"
class.THREE_R_TIME = 20

class:publish();

return class;
