local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇属護の遺跡_19層_ブルーゴブル", version=2.8, id=2005459});
class:inheritFromEnemy("2005457");


---闇属護の遺跡_19層_氷城塞ジオ＝ザグナスの召喚用


class:publish();

return class;