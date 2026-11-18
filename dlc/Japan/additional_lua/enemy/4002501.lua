--@additionalEnemy,4002509
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_NORMAL_フレイダル・絶", version=2.8, id=4002501});
class:inheritFromEnemy("4002502");

---------------------------------------------------------------------------------
-- ギミックカラムの既定値
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 20,          ---地上状態のaddSP
        addSP_fly = 30,      ---飛行状態のaddSP
        addSP_rage = 40,     ---飛行(怒り)状態のaddSP
        startAddSP = 0,      ---戦闘開始時奥義ゲージはHARDのみ
        attackDelay = 10,      ---地上状態のattack_delay
        attackDelay_fly = 7,   ---飛行状態のattack_delay
        attackDelay_rage = 5,  ---飛行(怒り)状態のattack_delay
        hitStop = 100,

        tgTimer = 30,
        tgLimit = 99,
        tgIconNum1 = 77,
        tgIconNum2 = 0,
        tgPosX = 50,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.5,

        tgTimer_2 = 1,
        tgLimit_2 = 99,
        tgIconNum1_2 = 26,
        tgIconNum2_2 = 0,
        tgPosX_2 = -50,
        tgPosY_2 = 0,
        tgScale_2 = 1,

        --- カスタムギミック値
        buffVal_132 = 100,
        buffVal_31 = 120,    ---飛行状態の物理回避率
        buffVal_31_2 = 350,  ---飛行(怒り)状態の物理回避率
        buffVal_112 = -30,
        subBarHP = 10000000,---エクストラゲージの破壊に必要なダメージ量（実数）
        hp0HpRate = 0.2,  ---setHPする倍率
        hp50CutInType = 1,---HP50の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hp0CutInType = 1, ---HP0の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hateIcon = 14,        ---ターゲットのフォーカスアイコン
        targetBuffValue_21 = 50,---ターゲットの被ダメージUP量(%)
        summonEnemyID = 4002509,---召喚するブルーゴブル(NORMAL)のエネミーID（0=召喚しない）
        summonCount = 3,      ---エクストラゲージ表示時に召喚するブルーゴブルの数
        buffVal_207 = 10,     ---氷衰の効果量（氷衰後遺症の値にも使う）
        freezeTimeAttack = 2, ---スキル3・スキル6の氷衰秒数
        freezeTimeSkill = 3,  ---奥義7・奥義8・奥義10の氷衰秒数
        freezePosOffsetX = 480,---初期位置のX方向オフセット（フレイダルの位置からの距離）
        freezeSequelaeFlg = 1,---氷衰後遺症（type234）を付けるか（1=付ける / 0=付けない）
        tgSubtractTimer = 1,  ---タイマーAが1周するたびに次周を短縮する秒数
        tgMinTimer = 20,      ---タイマーAの1周の下限秒数
        critDamageValue_17 = 20,---タイマーB1段あたりのクリティカルダメージUP量(%)
        critDamageMax = 20,     ---タイマーBの最大段数
        frostbiteFlg = 1,        ---凍傷ギミックの有効/無効（NORMAL/HARDのみ。1=有効 / 0=無効）
        frostbiteInterval = 1,   ---凍傷が1段積まれる間隔（秒）
        frostbiteHpValue = -2,   ---1段あたりの最大HP減少率(%)
        frostbiteAtkValue = -2,  ---1段あたりの攻撃力減少率(%)
        frostbiteHpMinValue = -98,---最大HP減少率の下限(%)。ここに達したら最大HPを1に固定する
        frostbiteIconMax = 99,   ---アイコンに表示する数値の上限（10%ごとに1）
        freezeTime = 15,      ---HPトリガー後にフレイダルが氷結する秒数（難易度別。NORMAL=15秒）
        freezeHpRegenValue_7 = 0.5,---氷結中のHP自然回復量（最大HPに対する割合(%)/秒）
        freezeTakeDamageRate = 0.01,---氷結中の被ダメージ補正（HPへ通るダメージ。エクストラゲージには等倍で入る）
    };
end

class:publish();

return class;
