local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超襲来マリカ_真EX_超マリカ", version=2.6, id=2084705});
class:inheritFromEnemy("2084710");

---真EX・極との差分
--- ・スキル構成が5種（奥義6〜13が無い）
--- ・HP50%の行動パターン変化が無い
--- ・HP0%フラグが無い
--- ・リーダーの与ダメージダウンが50%／エクストラゲージのHPが半分

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {                                     ---スキル1 -> スキル2 -> 繰り返し
        { ATTACK1 = 100 },
        { ATTACK2 = 100 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {                                     ---奥義3 -> 奥義4 -> 奥義3 -> 奥義4 -> 奥義5 -> 繰り返し
        { SKILL2 = 100 },
        { SKILL3 = 100 },
        { SKILL2 = 100 },
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    }
}

---左辺キー＝アニメーション／event.index、右辺＝スキル構成番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,                                    ---スキル1 通常攻撃          （attack1）
    ATTACK2 = 2,                                    ---スキル2 マギ・フォーカス   （skill1）
    SKILL2  = 3,                                    ---奥義3  フェーズ・ブレード （skill2）
    SKILL3  = 4,                                    ---奥義4  シンク・スマッシュ （skill3）
    SKILL5  = 5,                                    ---奥義5  ウル・オーケストラ （skill5／通常発動・カットインなし）
    SKILL6  = 5,                                    ---奥義5  HP80%フラグ専用    （skill5／奥義カットイン）
    SKILL7  = 5                                     ---奥義5  HP50%フラグ専用    （skill5／真奥義カットイン）
}

class.cutInSkill = {
    [6] = 0,                                        ---奥義5（HP80%）：奥義カットイン
    [7] = 1                                         ---奥義5（HP50%）：真奥義カットイン
}

---通常攻撃のアニメーション差し替え
class.ATTACK_ANIMATIONS = {
    [2] = "skill1"                                  ---スキル2 マギ・フォーカス
}

---奥義のアニメーション差し替え
class.SKILL_ANIMATIONS = {
    [6] = "skill5",                                 ---奥義5（HP80%フラグ専用）
    [7] = "skill5"                                  ---奥義5（HP50%フラグ専用）
}

---「燃焼状態のユニットのダメージ無効化無効」のINFOを出す奥義（真EXは奥義5のみ）
class.BURST_INFO_SKILLS = {
    [5] = true,                                     ---奥義5
    [6] = true,                                     ---奥義5（HP80%）
    [7] = true                                      ---奥義5（HP50%）
}

---HPフラグで発動する奥義のスロット番号
class.HP80_SKILL = 6;                               ---奥義5（奥義カットイン）
class.HP50_SKILL = 7;                               ---奥義5（真奥義カットイン）
---HP50%の行動パターン変化は真EX・極のみ
class.HP50_PATTERN = false;
---HP0%フラグは真EX・極のみ
class.USE_HP0_FLG = false;

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
---HP0%フラグが無いため、HP0%関連のGDキーは宣言しない（死んだカラムを作らない）
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 6,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---リーダーギミック
        leaderDmgDownVal = -50,     --リーダーユニットの与ダメージ%（マイナスでダウン）

        ---エクストラゲージ（フィールド装置）
        exGaugeHP = 50000,          --エクストラゲージのHP（リーダーのブレイクダメージのみ有効）
        exGaugeBreakAddSP = 25,     --エクストラゲージ破壊後のSP獲得量
        stunTime = 3,               --エクストラゲージ破壊時のボスの気絶秒数
        subBarPosY = 0,             --サブバーの表示位置（ボス座標からのオフセットY）

        ---エクストラゲージ表示中タイマー（パーティの最大HPダウン）
        exTgTimer = 8,              --インターバル秒数（[exTgTimer-アイコンの数字×exTgAccelStep]で加速）
        exTgAccelStep = 0.5,        --アイコンの数字1つあたり短縮する秒数
        exTgTimerMin = 1,           --最短インターバル秒数
        exTgLimit = 99,             --ループ上限
        exTgIconNum1 = 2,           --タイマーのアイコン番号（最大HPダウン）
        exTgIconNum2 = 0,
        exTgPosX = 0,
        exTgPosY = 0,
        exTgScale = 1,
        exTgBuffVal_2 = -5,         --1周ごとの最大HPダウン%
        exTgBuffMax = 99,           --重複上限（アイコンの数字）

        ---HPフラグ共通
        hpSkillInvincible = 20,     --HPフラグ奥義中の無敵秒数

        ---HP50%フラグ
        hp50AddSP = 35,             --HP50%以降のSP獲得量
        hp50AttackDelay = 4,        --HP50%以降のアタックディレイ
        hp50CritResistVal = -50,    --クリティカル耐性%（マイナスで被クリティカル率ダウン）
        hp50BurnResistVal = -50,    --パーティの燃焼耐性%（マイナスでダウン）

        ---耐性追加ギミック（既定OFF。1でON）
        extraResistEnable = 0,      --1でHP80%突破時の属性耐性／HP50%時の物魔耐性を有効化
        extraResistRate = 0.2,      --takeDamageValue補正の倍率
    };
end


class:publish();

return class;
