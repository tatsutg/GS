local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒美遊（神王フォーム）", version=2.3, id=108486412});
class:inheritFromUnit("108487412");

class:publish();

return class;
