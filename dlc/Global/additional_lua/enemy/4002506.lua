local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_EASY_唯海神ハーク", version=2.8, id=4002506});
class:inheritFromEnemy("4002508");

---------------------------------------------------------------------------------
-- ギミックカラムの既定値
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 10,
        startAddSP = 50,---戦闘開始時奥義ゲージ
        attackDelay = 6,
        hitStop = 100,

        --- カスタムギミック値
        buffVal_129 = 2,   ---奥義4ごとの継続ダメージ量（最大HPに対する割合(%)）
        buffMax_129 = 99,  ---継続ダメージの最大段数
        physicalTakeDamageRate = 0.2,---HP50以降の物理ダメージへのtakeDamageValue補正
        hp50AddSP = 15     ---HP50トリガー以降のaddSPの量
    };
end

class:publish();

return class;
