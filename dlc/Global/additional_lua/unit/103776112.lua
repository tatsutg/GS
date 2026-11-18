local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ハロウィンシャルロット", version=1.3, id=103776112});
class:inheritFromUnit("103777112");

class:publish();

return class;