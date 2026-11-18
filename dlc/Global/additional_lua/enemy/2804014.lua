local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="28章巨神ロイhard", version=1.3, id=2804014});
class:inheritFromUnit("501881250");

class:publish();

return class;