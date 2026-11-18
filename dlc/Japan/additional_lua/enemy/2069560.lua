local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="とある_上条当麻(EX1)", version=2.4, id=2069560});
class:inheritFromEnemy("2069570");

class:publish();

return class;