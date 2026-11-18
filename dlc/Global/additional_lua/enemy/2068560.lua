local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉄砕風紀委員長ヒューマ(EX1)", version=2.4, id=2068560});
class:inheritFromEnemy("2068570");

class:publish();

return class;