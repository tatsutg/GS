local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ラインハルト", version=2.8, id=108436112});
class:inheritFromUnit("108437112");

class:publish();

return class;
