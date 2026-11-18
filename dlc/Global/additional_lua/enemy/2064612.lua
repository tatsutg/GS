local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_NORMAL_ゴブル", version=2.8, id=2064612});
class:inheritFromEnemy("2064617");

---魔族の遺跡12層_NORMAL_ハイゴブル(2064611)の召喚用
---HPと威力（ハイゴブルの1/4のHP・スキル威力は半分）はデータ側で設定する
---撃破カウントバフはNORMALのハイゴブルが持たないため、加算処理は何もしない


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
-- 継承元のテーブルは使えない（子で宣言しないとギミックカラムに項目が出ない）ため全項目を並べる。
function class:getGimmickDefault()
    return {
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 6,            --アタックディレイ（ダメージを受ける1体目）
        attackDelay2nd = 11,        --アタックディレイ（無敵の2体目）
        attackDelay3rd = 17,        --アタックディレイ（無敵の3体目以降）
        hitStop = 100,              --ヒットストップ・時止め無効
    };
end


class:publish();

return class;
