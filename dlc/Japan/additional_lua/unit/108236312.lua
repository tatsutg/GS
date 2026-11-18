local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_ユーベル", version=1.8, id=108236312});
class:inheritFromUnit("108237312");


class:publish();

return class;