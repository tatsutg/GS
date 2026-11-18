local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒魔法少女シャル＆ヴァレリー（サマーver）", version=2.8, id=104336112});
class:inheritFromUnit("104337112");

class:publish();

return class;