local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒黒化英霊セイバー", version=1.3, id=107786512});
class:inheritFromUnit("107787512");

class:publish();

return class;