local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒クロエ(プリズマイリヤ)", version=1.3, id=107756112});
class:inheritFromUnit("107757112");

class:publish();

return class;