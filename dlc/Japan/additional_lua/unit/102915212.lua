local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="アデル", version=2.6, id=102915212});
class:inheritFromUnit("102916212");

class:publish();

return class;