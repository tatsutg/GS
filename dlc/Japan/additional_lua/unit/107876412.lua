local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒サイガ-0", version=1.3, id=107876412});
class:inheritFromUnit("107877412");

class:publish();

return class;