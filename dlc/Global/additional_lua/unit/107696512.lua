local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒アインズ", version=1.9, id=107696512});
class:inheritFromUnit("107697512");

class:publish();

return class;