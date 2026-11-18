local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="星5ネリム", version=2.6, id=101415312});
class:inheritFromUnit("101416312");

class:publish();

return class;