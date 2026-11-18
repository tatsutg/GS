local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="鬼武者セティス_覚醒前", version=1.3, id=104346212});
class:inheritFromUnit("104347212");

class:publish();

return class;
