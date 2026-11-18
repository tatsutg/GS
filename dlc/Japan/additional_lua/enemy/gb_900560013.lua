local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_メルキオン", version=1.3, id="gb_900550013"});
class:inheritFromEnemy("gb_901060013");

---グランドバトル EXボス 星12 銀翼魔従ヴァルザンデス の召喚ユニット

function class:setVariable(unit)
    self.difficultyLevel = 12;
end


class:publish();

return class;