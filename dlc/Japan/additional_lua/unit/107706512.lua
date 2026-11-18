local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒アルベド", version=1.3, id=107706512});
class:inheritFromUnit("107707512");

class:publish();

return class;