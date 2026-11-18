local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星5_ブラッディバット", version=1.3, id="gb_900100113"});
class:inheritFromEnemy("gb_901050013");

---グランドバトル EXボス 星5 光耀竜フォスラディウス の召喚ユニット

function class:setVariable(unit)
    self.difficultyLevel = 5;
end


class:publish();

return class;