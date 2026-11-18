local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="星4ネリム", version=1.3, id=101414312});
class:inheritFromUnit("101416312");

class:publish();

return class;