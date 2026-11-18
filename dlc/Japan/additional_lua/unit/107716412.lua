local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒シャルティア", version=1.3, id=107716412});
class:inheritFromUnit("107717412");

class:publish();

return class;