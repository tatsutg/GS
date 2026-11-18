--@additionalEnemy,4002503
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_EASY_フレイダル・絶", version=2.8, id=4002500});
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
        buffVal_31 = 60,     ---飛行状態の物理回避率
        buffVal_31_2 = 500,  ---飛行(怒り)状態の物理回避率（EASYは怒り状態まで到達しない）
        buffVal_112 = -30,
        subBarHP = 5000000,---エクストラゲージの破壊に必要なダメージ量（実数）
        hp0HpRate = 0.4,  ---setHPする倍率（EASYはHP0トリガーが無いので未使用）
        hp50CutInType = 1,---HP50の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hp0CutInType = 1, ---HP0の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hateIcon = 14,        ---ターゲットのフォーカスアイコン
        targetBuffValue_21 = 50,---ターゲットの被ダメージUP量(%)
        summonEnemyID = 4002503,---召喚するブルーゴブル(EASY)のエネミーID（0=召喚しない）
        summonCount = 2,      ---エクストラゲージ表示時に召喚するブルーゴブルの数
        buffVal_207 = 10,     ---氷衰の効果量（氷衰後遺症の値にも使う）
        freezeTimeAttack = 2, ---スキル3・スキル6の氷衰秒数
        freezeTimeSkill = 3,  ---奥義7・奥義8・奥義10の氷衰秒数
        freezePosOffsetX = 480,---初期位置のX方向オフセット（フレイダルの位置からの距離）
        freezeSequelaeFlg = 1,---氷衰後遺症（type234）を付けるか（1=付ける / 0=付けない）
        tgSubtractTimer = 1,  ---タイマーAが1周するたびに次周を短縮する秒数
        tgMinTimer = 20,      ---タイマーAの1周の下限秒数
        critDamageValue_17 = 20,---タイマーB1段あたりのクリティカルダメージUP量(%)
        critDamageMax = 20,     ---タイマーBの最大段数
        frostbiteFlg = 0,        ---凍傷ギミックの有効/無効（NORMAL/HARDのみ。1=有効 / 0=無効）
        frostbiteInterval = 1,   ---凍傷が1段積まれる間隔（秒）
        frostbiteHpValue = -2,   ---1段あたりの最大HP減少率(%)
        frostbiteAtkValue = -2,  ---1段あたりの攻撃力減少率(%)
        frostbiteHpMinValue = -98,---最大HP減少率の下限(%)。ここに達したら最大HPを1に固定する
        frostbiteIconMax = 99,   ---アイコンに表示する数値の上限（10%ごとに1）
        freezeTime = 10,      ---HPトリガー後にフレイダルが氷結する秒数（難易度別。EASY=10秒）
        freezeHpRegenValue_7 = 0.2,---氷結中のHP自然回復量（最大HPに対する割合(%)/秒）
        freezeTakeDamageRate = 0.01,---氷結中の被ダメージ補正（HPへ通るダメージ。エクストラゲージには等倍で入る）
    };
end

--------[[メッセージ]]--------
--- 凍傷ギミックが無いので戦闘開始INFOからその行を外す（他はHARDと同じ内容）
--- ※実行時の self はインスタンスなので self:parent() は使えない（自分自身が返り無限再帰になる）
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性、庇うキラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "累計ダメージが多いユニットをターゲット、ターゲットへのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過でユニットの状態異常耐性ダウン、暗闇で遅延", COLOR = Color.yellow}),
    }
    ---タイマーAが1周するたびに表示
    self.TIMERA_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMERA_MESSAGE1 or "状態異常耐性ダウン", COLOR = Color.yellow}),
    }
    ---氷衰ギミック発動時に表示（スキル3・6／奥義7・8・10）
    self.FREEZE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "ターゲットを氷衰", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "凍身回復：フレイダルが自身を氷結状態に移行", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "フレイダルが氷結状態のとき、HP自然回復、一定ダメージで解除", COLOR = Color.yellow}),
    }
    self.FLIGHT_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FLIGHT_MESSAGE1 or "飛行状態：攻撃速度・奥義上昇量・物理回避率アップ", COLOR = Color.yellow}),
    }
end

--------[[特殊行動]]--------
--- HP0トリガーはNORMAL/HARDのみなのでHP50だけにする
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
    }
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

class:publish();

return class;
