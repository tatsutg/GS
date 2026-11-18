local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真・夢幻封妖伝 参ノ巻EX2オルデウス", version=1.3, id=2043665});
class:inheritFromEnemy("2043660");

class:publish();

return class;