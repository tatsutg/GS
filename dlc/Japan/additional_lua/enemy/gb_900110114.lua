local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_竜牙兵", version=1.3, id="gb_900110114"});
class:inheritFromEnemy("gb_901060014");

---グランドバトル EXボス 星5 銀翼魔従ヴァルザンデス の召喚ユニット

function class:setVariable(unit)
    self.difficultyLevel = 5;
end


class:publish();

return class;