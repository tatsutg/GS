local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_HARD_ブルーゴブル", version=2.8, id=600000147});
class:inheritFromEnemy("600000148");

class.USE_DEAD_SP = true;           ---撃破でパーティの奥義ゲージアップ


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 0,                  --SP獲得量
        attackDelay = 4,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---被ダメージ補正（[dmgRateBase + dmgRateAdd × 状態異常の種類数]倍。上限 dmgRateMax、1未満のダメージは1）
        dmgRateBase = 0.05,         --状態異常が無いときの倍率
        dmgRateAdd = 0.5,           --状態異常1種類ごとに加算する倍率
        dmgRateMax = 2.0,           --倍率の上限

        ---撃破時
        deadAddSP = 5,              --撃破時のパーティの奥義ゲージアップ量
    };
end


class:publish();

return class;
