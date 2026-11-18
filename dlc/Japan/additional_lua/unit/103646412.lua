local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒神星リザ", version=1.3, id=103646412});
class:inheritFromUnit("103647412");

class:publish();

return class;