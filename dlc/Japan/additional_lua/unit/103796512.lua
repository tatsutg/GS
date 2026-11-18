local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_ハロウィンフォルテ", version=1.3, id=103796512});
class:inheritFromUnit("103797512");


class:publish();

return class;