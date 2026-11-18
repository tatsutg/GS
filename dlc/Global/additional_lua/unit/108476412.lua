local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒イリヤ（皇帝フォーム）", version=2.8, id=108476412});
class:inheritFromUnit("108477412");


class:publish();

return class;