local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_CODE XTF:SEEKER", version=2.7, id="gb_900570012"});
class:inheritFromEnemy("gb_901070012");
class.TEXT = summoner.Text:fetchByEnemyID("gb_901070012");

function class:getGimmickDefault()
    return {
        addSP = 20,
        startAddSP = 40,
        attackDelay = 5,
        hitStop = 100,

        difficultyLevel = 12,

        ---共通ギミック（ヘイト割合×hateGimmickRate＋hateGimmickBase ％の被ダメージ／被ダメージ SPBonusRate で奥義ゲージ+1）
        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        SPBonusRate = 60,

        ---種族・属性ギミック（1〜4種族の被ダメージ補正／1〜4属性の奥義ゲージ上昇量補正）
        raceDmgRate = {
            0.2,
            0.3,
            0.5,
            1.0
        },
        elementSPRate = {
            0.4,
            0.6,
            1.0,
            1.3
        },

        ---スキル3・スキル6／奥義8・奥義10（奥義ゲージダウン＝発動数×spDownValue、spDownMax まで。0で無し）
        attackBuffValue_21 = 30,
        skillBuffValue_1 = -2000,
        spDownValue = 40,
        spDownMax = 240,

        ---ファンネル（スキル2で1機追加、最大 funnelMax 機。レーザーのダメージはファンネル数倍）
        funnelMax = 5,
        funnelLife = 10,

        ---エクストラゲージ（HP＝break_capacity×(exGaugeHPBaseRate＋exGaugeHPAddRate×表示回数)％）
        exGaugeDmgRate = 0.1,
        exGaugeHPBaseRate = 25,
        exGaugeHPAddRate = 2,
        exGaugeStunTime = 1,

        ---タイマー（1周ごとに効果、tgLimit 周で終了。効果量0は効果なし）
        tgTimer = 1,
        tgLimit = 20,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        timerHp80BuffValue_54 = -10,
        timerHp50BuffValue_22 = 2,
        timerHp30BuffValue_54 = -10,
        timerHp0BuffValue_17 = 0,

        ---HPトリガー
        hp50BuffValue_23 = -150,
        hp30BuffValue_27 = -30,
        hp30AddSP = 40,
        hp0AddSP = 50,
        hp0HealRate = 0.5
    }
end

class:publish();

return class;
