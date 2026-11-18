local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒アリステラ・オルビス", version=1.3, id=103686212});
class:inheritFromUnit("103687212");

class:publish();

return class;