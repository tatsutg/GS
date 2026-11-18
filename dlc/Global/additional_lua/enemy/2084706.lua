local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超襲来マリカ_真EX_SX-202型・改", version=2.6, id=2084706});
class:inheritFromEnemy("2084711");

---真EX・極との差分はタイマーギミック（真EX・極のみ）だけ。
---USE_START_TIMER が false のとき、タイマーの生成・タイマー用バフ・タイマーのINFOは
---すべて親側で生成されないため、タイマー用のGDキーは宣言しない（死んだカラムを作らない）。
class.USE_START_TIMER = false;

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 5,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効
        sizeScale = 2,              --見た目の倍率（size=2倍）

        ---ダメージ耐性（パーティの種族数）
        raceCountMax = 4,           --補正が等倍になる種族数（これ以上は打ち止め）
        raceRateBase = 2,           --補正 ×[1/raceRateBase^（raceCountMax-種族数）]

        ---討伐報酬（早く倒すほどパーティのブレイク力アップ）
        rewardBase = 100,           --[rewardBase-経過秒数]%アップ
        rewardMin = 10,             --最低保証%

        ---HP50%フラグ
        hp50AddSP = 35,             --HP50%以降のSP獲得量
        hp50DmgUpVal = 50,          --HP50%以降の自身のダメージアップ%
        hpSkillInvincible = 15,     --HPフラグ奥義中の無敵秒数
    };
end


class:publish();

return class;
