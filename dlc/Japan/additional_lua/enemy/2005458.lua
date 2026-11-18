--@additionalEnemy,2005459
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="闇属護の遺跡_19層_氷城塞ジオ＝ザグナス", version=2.8, id=2005458});
class:inheritFromEnemy("2005456");


function class:setEnemyIDs()
    self.summonEnemyID = 2005459;
end


class:publish();

return class;