local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒水着ルヴィア＆凛", version=1.3, id=108016312});
class:inheritFromUnit("108017312");


class:publish();

return class;