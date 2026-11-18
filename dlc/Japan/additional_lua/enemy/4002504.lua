local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_EASY_水麗姫ヨミ", version=2.8, id=4002504});
class:inheritFromEnemy("4002512");

---------------------------------------------------------------------------------
-- ギミックカラムの既定値
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 10,
        startAddSP = 0,
        attackDelay = 6,
        hitStop = 100,

        --- カスタムギミック値
        buffVal_59 = -50---奥義4使用時の氷結耐性DOWN量(%)（氷結回避率にも同じ値を使う）
    };
end

class:publish();

return class;
