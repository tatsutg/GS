--@additionalEnemy,2064016
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡12層_HARD_双頭魔獣ジンガルム", version=2.8, id=2064015});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {                                         ---HP50%フラグまで
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK3 = 100 },
    },
    FURY = {                                            ---HP50%フラグ後
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK4 = 100 },
        { ATTACK5 = 100 },
        { ATTACK6 = 100 },
    },
    PIYORI = {                                          ---ピヨリ時
        { ATTACK7 = 100 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL2 = 100 },
    },
    PIYORI = {                                          ---ピヨリ時
        { SKILL1 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---噛みつき             (attack1)
    ATTACK2 = 2,    ---尻尾ビンタ           (attack2)
    ATTACK3 = 3,    ---爪ひっかき           (attack3)
    ATTACK4 = 4,    ---炎ブレス             (attack4)
    ATTACK5 = 5,    ---咆哮                 (attack5)
    ATTACK6 = 6,    ---突き上げ             (attack6)
    ATTACK7 = 7,    ---ピヨリ攻撃           (attack7)
    SKILL1  = 8,    ---インフェルノチャージ (skill1)
    SKILL2  = 9,    ---メギドフレイム       (skill2)
    SKILL3  = 10,   ---メギドフレイム       (skill2を流用／HPフラグ専用)
}

class.cutInSkill = {
    --[3] = 1
}

---怨嗟ノ獄門のカウント対象（毒・暗闇・病気・燃焼）
class.CURSE_STATUS_LIST = {90,93,94,97};


--------[[バフ]]--------
function class:setBuffBoxList()
    ---物理／魔法耐性（[1]=物理 [2]=魔法）
    self.RESIST_BUFF_LIST = {
        [1] = {
            ID = 206401501,
            BUFF_ID = 21,                       ---被ダメージ（負値＝軽減）
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 21,                          ---物理耐性
            SCRIPT = { SCRIPT_ID = 2 },         ---受けるダメージが物理のとき
            MAX = self.GD.resistMax,
        },
        [2] = {
            ID = 206401502,
            BUFF_ID = 21,
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 22,                          ---魔法耐性
            SCRIPT = { SCRIPT_ID = 3 },         ---受けるダメージが魔法のとき
            MAX = self.GD.resistMax,
        },
    }

    ---時間経過によるパーティ被ダメージアップ
    self.TG_BUFF_BOX_LIST = {
        [1] = {
            ID = 206401503,
            BUFF_ID = 21,                       ---被ダメージ（正値＝被ダメージアップ）
            VALUE = self.GD.tgBuffVal_21,
            DURATION = 999999,
            ICON = 139,
            MAX = self.GD.tgBuffMax,            ---重複＆アイコンに数字表示
        },
    }

    ---ギリウス撃破カウント（HP75%ギミック中のみ存在。ギリウス側のdead()が加算する）
    self.GIRISU_COUNT_BUFF = {
        [1] = {
            ID = 206401504,
            BUFF_ID = 0,                        ---効果なし・カウント保持専用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            MAX = 99,
        },
    }

    ---血肉ノ獄門を先に破壊した場合の与ダメージアップ（上限なし）
    self.BLOOD_BUFF_LIST = {
        [1] = {
            ID = 206401505,
            BUFF_ID = 17,                       ---与ダメージ
            VALUE = 0,                          ---breakBothGateで経過秒数から算出して上書きする
            DURATION = 999999,
            ICON = 26,
        },
    }

    ---ゲージ破壊時の気絶
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 206401506,
            BUFF_ID = 89,                       ---気絶
            VALUE = 100,
            DURATION = self.GD.stunTime,
            ICON = 0,
        },
    }

    ---ピヨリ（継続時間の管理用。効果は行動パターンとaddSPで表現する）
    self.PIYORI_BUFF_LIST = {
        [1] = {
            ID = 206401507,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.GD.piyoriTime,
            ICON = 0,
        },
    }
end


--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message;
end

function class:setMessageBoxList()
    ---戦闘開始時
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "時間経過でパーティの被ダメージアップ", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "装備ダメージで一定時間遅延", COLOR = Color.white}),
    }

    ---HP75%（[1]=物理 [2]=魔法　累計ダメージが大きかった方を出す）
    self.HP75_RESIST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_RESIST_MESSAGE1 or "物理耐性アップ・行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_RESIST_MESSAGE2 or "魔法耐性アップ・行動速度アップ", COLOR = Color.yellow}),
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "ジンガルム：ダメージ耐性", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE2 or "一定数ギリウス撃破でダメージ耐性解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE3 or "ギリウス：氷結で撃破", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE4 or "ギリウス：被クリティカルダメージ耐性", COLOR = Color.red}),
    }
    self.HP75_GAUGE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_GAUGE_BREAK_MESSAGE1 or "ジンガルム：ダメージ耐性解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_GAUGE_BREAK_MESSAGE2 or "ジンガルム：気絶・一定時間弱体化", COLOR = Color.red}),
    }

    ---HP50%（[1]=物理 [2]=魔法）
    self.HP50_RESIST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_RESIST_MESSAGE1 or "物理耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_RESIST_MESSAGE2 or "魔法耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }

    ---HP25%（[1]=物理 [2]=魔法）
    self.HP25_RESIST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_RESIST_MESSAGE1 or "物理耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_RESIST_MESSAGE2 or "魔法耐性アップ・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "ジンガルム：ダメージ耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "獄門を完全破壊でダメージ耐性解除", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE3 or "血肉ノ獄門：奥義使用で減少", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE4 or "怨嗟ノ獄門：毒・燃焼・暗闇・病気付与で減少", COLOR = Color:new(192,192,192)}),
    }

    ---獄門破壊時
    self.BLOOD_GATE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BLOOD_GATE_BREAK_MESSAGE1 or "血肉ノ獄門破壊：怨嗟ノ獄門を破壊せよ！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BLOOD_GATE_BREAK_MESSAGE2 or "怨嗟ノ獄門破壊が遅いほどジンガルムの与ダメージアップ", COLOR = Color.red}),
    }
    self.CURSE_GATE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.CURSE_GATE_BREAK_MESSAGE1 or "怨嗟ノ獄門破壊：血肉ノ獄門を破壊せよ！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CURSE_GATE_BREAK_MESSAGE2 or "血肉ノ獄門破壊が遅いほどジンガルムのHP回復", COLOR = Color.red}),
    }
    self.HP25_GAUGE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_GAUGE_BREAK_MESSAGE1 or "ジンガルム：獄門破壊成功！ダメージ耐性解除！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_GAUGE_BREAK_MESSAGE2 or "ジンガルム：気絶・一定時間弱体化", COLOR = Color.red}),
    }

    ---ギリウス撃破カウント
    self.GIRISU_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GIRISU_DEAD_MESSAGE1 or "%d体撃破！", COLOR = Color.red}),
    }

    ---トリガー番号 → 物理／魔法耐性メッセージ
    self.RESIST_MESSAGE_LIST = {
        [1] = self.HP75_RESIST_MESSAGE_LIST,
        [2] = self.HP50_RESIST_MESSAGE_LIST,
        [3] = self.HP25_RESIST_MESSAGE_LIST,
    }
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp25(status) end,
            HP = 25,
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

function class:hp75(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);                             ---状態異常を回復
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                       ---奥義10（SKILL3スロット）
            self.saveBP = self.gameUnit:getBurstPoint();             ---直前の奥義ゲージを引き継ぐ
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setAttackDelay(self.GD.hp75AttackDelay);      ---行動速度アップ
        self.gameUnit:setInvincibleTime(self.GD.hpInvincibleTime);
        self.hpSkillFLG = true;
        self.hpDmgMult = 0;                                         ---打ち終わるまでダメージ0・ブレイク0
        self:showMessage(self.HP75_MESSAGE_LIST);
        self:execResistBuff(1);                                     ---累計ダメージの大きい方の耐性アップ
        self:startGirisuGauge();                                    ---エクストラゲージ＆ギリウス召喚開始
    end
end

function class:hp50(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpInvincibleTime);
        self.hpSkillFLG = true;
        self.hpDmgMult = 0;
        self.furyFLG = true;                                        ---ピヨリ明けの復帰先をFURYにする
        self.saveSpValue = self.GD.hp50AddSP;
        ---ピヨリ中はピヨリの設定を維持し、明けたときに反映させる
        if not self.piyoriFLG then
            self.spValue = self.GD.hp50AddSP;                       ---奥義ゲージ上昇量アップ
            self:initAttackWeight({FURY = 100});                    ---行動パターン変化
        end
        self:execResistBuff(2);
    end
end

function class:hp25(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpInvincibleTime);
        self.hpSkillFLG = true;
        self.hpDmgMult = 0;
        self.saveSpValue = self.GD.hp25AddSP;
        if not self.piyoriFLG then
            self.spValue = self.GD.hp25AddSP;
        end
        self:showMessage(self.HP25_MESSAGE_LIST);
        self:execResistBuff(3);
        self:startGateGauge();                                      ---獄門2ゲージ表示開始
    end
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 7,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---被ダメージアップタイマー（戦闘開始から動作）
        tgTimer = 15,               --1周の秒数
        tgLimit = 99,               --ループ上限
        tgIconNum1 = 139,           --被ダメージアップアイコン
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgBuffVal_21 = 20,          --1周ごとのパーティ被ダメージアップ%
        tgBuffMax = 99,             --重複上限（アイコンの数字）
        tgDelayTime = 3,            --装備ダメージによる遅延秒数
        tgDelayRate = 100,          --遅延の発動確率%（100=必ず発動 / 50=確率1/2）
        tgDelaySpeed = 0.5,         --遅延中のタイマー速度（0.5=半速 / 0=完全停止）

        ---物理／魔法耐性アップ（HPフラグ毎）
        resistVal_21 = -50,         --耐性アップ量（負値＝被ダメージ軽減）
        resistMax = 3,              --HPフラグ3回ぶんの重複上限

        ---HPフラグ共通
        hpInvincibleTime = 10,      --HPフラグ奥義中の無敵時間
        hp75AttackDelay = 5,        --HP75%以降のアタックディレイ
        hp50AddSP = 25,             --HP50%以降のSP獲得量
        hp25AddSP = 35,             --HP25%以降のSP獲得量

        ---HP75% エクストラゲージ＆召喚
        summonNum = 4,              --場に維持するギリウスの数
        exGaugeHP75 = 50,           --エクストラゲージHP
        girisuKillDmg = 10,         --ギリウス1体撃破でゲージに与えるダメージ

        ---HP25% 獄門ゲージ
        exGaugeBlood = 50,          --血肉ノ獄門HP
        exGaugeCurse = 30,          --怨嗟ノ獄門HP
        bloodGateDmg = 1,           --奥義1回で血肉ノ獄門に与えるダメージ
        curseGateDmg = 1,           --状態異常1付与で怨嗟ノ獄門に与えるダメージ
        bloodDmgUpRate = 3,         --血肉を先に破壊：経過秒数×N% 与ダメージアップ
        curseHealRate = 2,          --怨嗟を先に破壊：経過秒数×N% HP回復
        curseHealMax = 100,         --HP回復の上限%

        ---気絶・ピヨリ
        stunTime = 3,               --ゲージ破壊時の気絶秒数
        piyoriTime = 10,            --気絶復帰後のピヨリ秒数
        piyoriAddSP = 10,           --ピヨリ中のSP獲得量

        ---サブバー表示位置（ボス座標からのオフセットY）
        subBarPosY75 = 0,           --HP75%ゲージ（胴体）
        subBarPosYBlood = 25,       --血肉ノ獄門
        subBarPosYCurse = 0,        --怨嗟ノ獄門
    };
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault());
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;
    self.hpDmgMult = nil;

    ---物理／魔法の累計ダメージ
    self.physicalDamage = 0;
    self.magicDamage = 0;
    self.furyFLG = false;

    ---被ダメージアップタイマー（戦闘開始から動作）
    self.timeIndex1 = megast.Battle:getInstance():createExtraTimer(
        self.GD.tgTimer, self.GD.tgLimit,
        self.GD.tgIconNum1, self.GD.tgIconNum2,
        self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed1 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1);
    self.tgDelayTime = 0;               ---装備ダメージによる遅延の残り秒数

    ---HP75% ギリウスゲージ＆召喚
    self.summonID = 2064016;             ---冥獣ギリウス
    self.girisuGaugeFLG = false;
    self.girisuKillCount = 0;            ---メッセージ表示済みのカウント
    self.friendCount = 0;
    self.SUB_HP_GIRISU = self.GD.exGaugeHP75;

    self.subBarGirisu = BattleControl:get():createSubBar();
    self.subBarGirisu:setWidth(200);
    self.subBarGirisu:setHeight(13);
    self.subBarGirisu:setPercent(0);
    self.subBarGirisu:setVisible(false);
    self.subBarGirisu:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
    self.subBarGirisu:setBarColor(255,255,255);

    ---HP25% 獄門2ゲージ
    self.gateFLG = false;
    self.bloodBreakFLG = false;
    self.curseBreakFLG = false;
    self.gateFirst = 0;                 ---先に壊れたゲージ（2=血肉 3=怨嗟）
    self.gateElapsed = 0;               ---片方だけ壊れている間の経過秒数
    self.bloodDamage = 0;
    self.curseDamage = 0;
    self.playerSkillFlg = {};           ---プレイヤー別の奥義中フラグ
    self.bossDeBuffFlg = {};            ---状態異常別の付与中フラグ
    self.SUB_HP_BLOOD = self.GD.exGaugeBlood;
    self.SUB_HP_CURSE = self.GD.exGaugeCurse;

    self.subBarBlood = BattleControl:get():createSubBar();
    self.subBarBlood:setWidth(200);
    self.subBarBlood:setHeight(13);
    self.subBarBlood:setPercent(0);
    self.subBarBlood:setVisible(false);
    self.subBarBlood:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
    self.subBarBlood:setBarColor(255,153,204);      ---血肉ノ獄門

    self.subBarCurse = BattleControl:get():createSubBar();
    self.subBarCurse:setWidth(200);
    self.subBarCurse:setHeight(13);
    self.subBarCurse:setPercent(0);
    self.subBarCurse:setVisible(false);
    self.subBarCurse:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
    self.subBarCurse:setBarColor(192,192,192);      ---怨嗟ノ獄門

    ---気絶・ピヨリ
    self.stunFLG = false;
    self.piyoriFLG = false;
    self.saveSpValue = self.GD.addSP;   ---ピヨリ明けに戻すSP獲得量

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---エクストラタイマーの速度制御（被ダメージアップ／獄門）
    self:extraTimerOperation(event.unit);

    ---装備ダメージによる遅延の残り時間
    if self.tgDelayTime > 0 then
        self.tgDelayTime = self.tgDelayTime - event.deltaTime;
        if self.tgDelayTime < 0 then self.tgDelayTime = 0; end
    end

    ---HP75% ギリウスゲージ＆召喚
    if self.girisuGaugeFLG then
        self:girisuKillCheck();
        self:girisuGaugeControll(event.unit);
        if self.girisuGaugeFLG then
            if megast.Battle:getInstance():isHost() then
                self:girisuOperation(event.unit);
            end
        end
    end

    ---HP25% 獄門2ゲージ
    if self.gateFLG then
        self:gateGaugeControll(event.unit);
        if megast.Battle:getInstance():isHost() then
            self:gateOperation();
        end
        ---片方だけ壊れている間の経過秒数（ホストのみ計測。ゲストへはイベント7で配る）
        if self.gateFirst ~= 0 and megast.Battle:getInstance():isHost() then
            self.gateElapsed = self.gateElapsed + event.deltaTime;
        end
    end

    ---気絶→ピヨリの状態遷移
    self:stunOperation(event.unit);

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end


--===================================================================================================================
-- エクストラタイマー
--===================================================================================================================
---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex1 then
        self:unitAddBuff(self.TG_BUFF_BOX_LIST[1]);      ---パーティ全体の被ダメージアップ
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    ---被ダメージアップタイマー
    if self.timeIndex1 ~= nil then
        local speed = 1;
        ---ブレイク中・無敵中・HPフラグ奥義中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG == true then
            speed = 0;
        elseif self.tgDelayTime > 0 then
            speed = self.GD.tgDelaySpeed;               ---装備ダメージによる遅延
        end
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1) ~= speed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex1, speed);
        end
        self.timeSpeed1 = speed;
    end
end

function class:startTimerDelay()
    self.tgDelayTime = self.GD.tgDelayTime;
end

function class:removeTimers()
    if self.timeIndex1 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex1,1,0,true);
        self.timeIndex1 = nil;
    end
end


--===================================================================================================================
-- 物理／魔法の累計ダメージ耐性アップ
--===================================================================================================================
---累計ダメージの大きい方の耐性をアップ（ホストが判定してゲストへ配る）
function class:execResistBuff(triggerIndex)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    local resistType = self.magicDamage > self.physicalDamage and 2 or 1;   ---1=物理 2=魔法
    self:applyResistBuff(triggerIndex,resistType);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,8,triggerIndex * 10 + resistType);
end

function class:applyResistBuff(triggerIndex,resistType)
    self:execAddBuff(self.gameUnit,self.RESIST_BUFF_LIST[resistType]);
    self:showMessage(self.RESIST_MESSAGE_LIST[triggerIndex],resistType);
    ---累計はHPフラグ毎にリセットし、リセットした時からの累計とする
    self.physicalDamage = 0;
    self.magicDamage = 0;
end


--===================================================================================================================
-- HP75% エクストラゲージ＆ギリウス召喚
--===================================================================================================================
function class:startGirisuGauge()
    self.girisuGaugeFLG = true;
    self.girisuKillCount = 0;
    ---撃破カウント用バフを付与し、カウントを0にする
    self:execAddBuff(self.gameUnit,self.GIRISU_COUNT_BUFF[1]);
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.GIRISU_COUNT_BUFF[1].ID);
    if cond ~= nil then
        cond:setNumber(0);
        megast.Battle:getInstance():updateConditionView();
    end
end

function class:breakGirisuGauge(unit)
    if not self.girisuGaugeFLG then return; end
    self.girisuGaugeFLG = false;
    self.subBarGirisu:setVisible(false);
    ---全滅処理でカウントが増えないよう、先にカウントバフを除去する
    self:removeBuff(unit,self.GIRISU_COUNT_BUFF[1].ID);
    self:killAllGirisu();
    self:showMessage(self.HP75_GAUGE_BREAK_MESSAGE_LIST);
    self:startStun(unit);
end

---撃破カウントをバフから読む（バフが無ければ0）
function class:getGirisuKillCount()
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.GIRISU_COUNT_BUFF[1].ID);
    if cond == nil then
        return 0;
    end
    return cond:getNumber();
end

---撃破カウントの増分を検知してINFOを出す
function class:girisuKillCheck()
    local killCount = self:getGirisuKillCount();
    if killCount > self.girisuKillCount then
        self.girisuKillCount = killCount;
        self:showCountMessage(self.GIRISU_DEAD_MESSAGE_LIST[1],killCount);
    end
end

function class:girisuGaugeControll(unit)
    local damage = self.girisuKillCount * self.GD.girisuKillDmg;
    self.subBarGirisu:setPositionX(unit:getPositionX());
    self.subBarGirisu:setPositionY(unit:getPositionY() + self.GD.subBarPosY75);
    self.subBarGirisu:setVisible(true);
    self.subBarGirisu:setPercent(100 * (self.SUB_HP_GIRISU - damage) / self.SUB_HP_GIRISU);
    ---削り切り検知はホストのみ
    if self.SUB_HP_GIRISU - damage <= 0 and megast.Battle:getInstance():isHost() then
        self:breakGirisuGauge(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,100000);
    end
end

function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID);
                break;
            end
        end
    end
end

function class:findFriend()
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil and myTeamUnit:getEnemyID() == self.summonID then
            self.friendCount = self.friendCount + 1;
        end
    end
end

---場に summonNum 体いるように召喚し続ける（1フレーム1体）
function class:girisuOperation(unit)
    self:findFriend();
    if self.friendCount < self.GD.summonNum then
        self:summon(unit,self.summonID);
    end
end

---ギリウスを全てDead処理
function class:killAllGirisu()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getEnemyID() == self.summonID then
            u:setHP(0);
        end
    end
end


--===================================================================================================================
-- HP25% 獄門2ゲージ
--===================================================================================================================
function class:startGateGauge()
    self.gateFLG = true;
    self.bloodBreakFLG = false;
    self.curseBreakFLG = false;
    self.gateFirst = 0;
    self.gateElapsed = 0;
    self.bloodDamage = 0;
    self.curseDamage = 0;
    self.playerSkillFlg = {};
    self.bossDeBuffFlg = {};
end

---プレイヤーの奥義発動回数を数える（HIT数ではなく発動回数）
---getBurstState() が active になった瞬間を1カウントとする。
--- ○数える：奥義・真奥義・超覚醒奥義・ファントムバレット・アルビオンブレイズ・主人公化・
---          変身後の奥義（すべて takeSkillWithCutin 経由で active になる）
--- ○連携奥義：発動者とパートナーの両方が active になるので2カウント（ユニット2体分）
--- ×数えない：通常スキル・装備スキル（Battle::useSkill の非バースト経路は
---          setUnitState(kUnitState_skill) の直後に resetStates() で burstState を none にする）
---※ kUnitState_skill で判定すると通常スキル・装備スキルまで拾うので使わない
function class:checkPlayerSkill()
    local count = 0;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getBurstState() == kBurstState_active then
            if not self.playerSkillFlg[i] then
                self.playerSkillFlg[i] = true;
                count = count + 1;
            end
        else
            self.playerSkillFlg[i] = false;
        end
    end
    return count;
end

---ボスへの状態異常付与数を数える（毒・暗闇・病気・燃焼の立ち上がり）
function class:checkBossDeBuff()
    local count = 0;
    for _,statusID in ipairs(self.CURSE_STATUS_LIST) do
        if self.gameUnit:getTeamUnitCondition():findConditionWithType(statusID) ~= nil then
            if not self.bossDeBuffFlg[statusID] then
                self.bossDeBuffFlg[statusID] = true;
                count = count + 1;
            end
        else
            self.bossDeBuffFlg[statusID] = false;
        end
    end
    return count;
end

---獄門ゲージのカウント反映（ホストのみ）
function class:gateOperation()
    ---奥義発動回数 → 血肉ノ獄門
    if not self.bloodBreakFLG then
        local skillCount = self:checkPlayerSkill();
        if skillCount > 0 then
            self.bloodDamage = self.bloodDamage + self.GD.bloodGateDmg * skillCount;
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,200000 + math.floor(self.bloodDamage));
        end
    end
    ---状態異常付与数 → 怨嗟ノ獄門
    if not self.curseBreakFLG then
        local deBuffCount = self:checkBossDeBuff();
        if deBuffCount > 0 then
            self.curseDamage = self.curseDamage + self.GD.curseGateDmg * deBuffCount;
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,300000 + math.floor(self.curseDamage));
        end
    end
end

function class:gateGaugeControll(unit)
    if not self.bloodBreakFLG then
        self.subBarBlood:setPositionX(unit:getPositionX());
        self.subBarBlood:setPositionY(unit:getPositionY() + self.GD.subBarPosYBlood);
        self.subBarBlood:setVisible(true);
        self.subBarBlood:setPercent(100 * (self.SUB_HP_BLOOD - self.bloodDamage) / self.SUB_HP_BLOOD);
        if self.SUB_HP_BLOOD - self.bloodDamage <= 0 and megast.Battle:getInstance():isHost() then
            ---経過秒数はホストの値をゲストへ配る（効果量がクライアント間でズレないように）
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,200000 + math.floor(self.gateElapsed));
            self:breakBloodGate(unit);
        end
    end
    if not self.curseBreakFLG then
        self.subBarCurse:setPositionX(unit:getPositionX());
        self.subBarCurse:setPositionY(unit:getPositionY() + self.GD.subBarPosYCurse);
        self.subBarCurse:setVisible(true);
        self.subBarCurse:setPercent(100 * (self.SUB_HP_CURSE - self.curseDamage) / self.SUB_HP_CURSE);
        if self.SUB_HP_CURSE - self.curseDamage <= 0 and megast.Battle:getInstance():isHost() then
            ---経過秒数はホストの値をゲストへ配る（効果量がクライアント間でズレないように）
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,300000 + math.floor(self.gateElapsed));
            self:breakCurseGate(unit);
        end
    end
end

function class:breakBloodGate(unit)
    if self.bloodBreakFLG then return; end
    self.bloodBreakFLG = true;
    self.subBarBlood:setVisible(false);
    if self.curseBreakFLG then
        self:breakBothGate(unit);                           ---2枚目 → 完全破壊
    else
        ---1枚目のときだけ「もう片方を破壊せよ」のINFOを出す
        self:showMessage(self.BLOOD_GATE_BREAK_MESSAGE_LIST);
        self.gateFirst = 2;                                 ---血肉が先。以降 gateElapsed の計測を開始する
        self.gateElapsed = 0;
    end
end

function class:breakCurseGate(unit)
    if self.curseBreakFLG then return; end
    self.curseBreakFLG = true;
    self.subBarCurse:setVisible(false);
    if self.bloodBreakFLG then
        self:breakBothGate(unit);
    else
        ---1枚目のときだけ「もう片方を破壊せよ」のINFOを出す
        self:showMessage(self.CURSE_GATE_BREAK_MESSAGE_LIST);
        self.gateFirst = 3;                                 ---怨嗟が先。以降 gateElapsed の計測を開始する
        self.gateElapsed = 0;
    end
end

function class:breakBothGate(unit)
    self.gateFLG = false;                                   ---takeDamageValue補正の解除
    local sec = math.floor(self.gateElapsed);
    if self.gateFirst == 2 then
        ---血肉が先：怨嗟破壊までの秒数×3% 与ダメージアップ（上限なし）
        self.BLOOD_BUFF_LIST[1].VALUE = sec * self.GD.bloodDmgUpRate;
        self:execAddBuff(unit,self.BLOOD_BUFF_LIST[1]);
    elseif self.gateFirst == 3 then
        ---怨嗟が先：血肉破壊までの秒数×2% HP回復（100%MAX）
        ---addHP は Lua に公開されていないので setHP で加算する
        local rate = math.min(sec * self.GD.curseHealRate, self.GD.curseHealMax);
        local hpMax = unit:getCalcHPMAX();
        unit:setHP(math.min(unit:getHP() + math.floor(hpMax * rate * 0.01), hpMax));
    end
    self:showMessage(self.HP25_GAUGE_BREAK_MESSAGE_LIST);
    self:startStun(unit);
end


--===================================================================================================================
-- 気絶 → ピヨリ
--===================================================================================================================
---ゲージ破壊時の気絶（stunTime秒）
function class:startStun(unit)
    self.stunFLG = true;
    self.piyoriFLG = false;
    self:execAddBuff(unit,self.STUN_BUFF_LIST[1]);
end

---気絶復帰後のピヨリ（piyoriTime秒）
function class:startPiyori(unit)
    self.stunFLG = false;
    self.piyoriFLG = true;
    self.spValue = self.GD.piyoriAddSP;                 ---addSP=10
    self:initAttackWeight({PIYORI = 100});              ---スキル7のみ
    self:initSkillWeight({PIYORI = 100});               ---奥義8のみ
    self:execAddBuff(unit,self.PIYORI_BUFF_LIST[1]);
end

---ピヨリ終了。HP50%を通過済みならFURYへ、未通過ならDEFAULTへ戻す
function class:endPiyori()
    self.piyoriFLG = false;
    self.spValue = self.saveSpValue;
    self:initAttackWeight(self.furyFLG and {FURY = 100} or {DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
end

---気絶／ピヨリの経過監視
function class:stunOperation(unit)
    if self.stunFLG then
        ---気絶が明けたらピヨリへ（移行タイミングはホストが決めて配る）
        if megast.Battle:getInstance():isHost()
        and unit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST[1].ID) == nil then
            self:startPiyori(unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
        end
    elseif self.piyoriFLG then
        ---ピヨリバフが切れたら行動パターンを戻す
        if unit:getTeamUnitCondition():findConditionWithID(self.PIYORI_BUFF_LIST[1].ID) == nil then
            self:endPiyori();
        end
    end
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
-- Spineに addSP イベントが無いためユニットテンプレートを採用している。
-- SP加算は takeAttack() 側が担当する。
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0);
            self.hpSkillFLG = false;
            self.hpDmgMult = nil;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:removeTimers();
    self:killAllGirisu();                   ---ギリウスが残っていた場合の保険
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
    self:removeTimers();
    self:killAllGirisu();
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        self.hpDmgMult = nil;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;

    ---SKILL3（奥義10 メギドフレイム）は SKILL2 と同じ skill2 アニメを使う
    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill2");
    end

    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    ---① HPフラグ奥義中はダメージ0
    if self.hpDmgMult ~= nil then
        event.value = math.floor(event.value * self.hpDmgMult);
    end

    ---② 物理／魔法の累計ダメージを集計（ホストのみ・HPフラグ毎にリセット）
    if megast.Battle:getInstance():isHost() then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            self.physicalDamage = self.physicalDamage + event.value;
        elseif attribute == 2 then
            self.magicDamage = self.magicDamage + event.value;
        end
    end

    ---③ 装備ダメージでタイマーを遅延させる（ホストのみ判定・遅延中は重複しない）
    if megast.Battle:getInstance():isHost() and self.tgDelayTime <= 0 then
        local skillType = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType == 3 or skillType == 6 then
            if summoner.Random.range(1,100) <= self.GD.tgDelayRate then
                self:startTimerDelay();
                megast.Battle:getInstance():sendEventToLua(self.scriptID,10,1);
            end
        end
    end

    ---④ エクストラゲージ表示中はボスの全ダメージを1にする（HPフラグ奥義中の0は維持）
    if self.hpDmgMult == nil and (self.girisuGaugeFLG or self.gateFLG) then
        event.value = 1;
    end

    ---⑤ HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないため属性・装備の判定はできない）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    elseif self.hpDmgMult ~= nil then
        event.value = math.floor(event.value * self.hpDmgMult);
    elseif self.girisuGaugeFLG or self.gateFLG then
        ---エクストラゲージ表示中はボスの全ダメージを1にする
        event.value = 1;
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit); ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    ---HPフラグは発動から奥義を打ち終わるまでブレイク0
    if self.hpSkillFLG == true then
        return 0;
    end
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    self.breakFlg = true;
    return 1;
end


--===================================================================================================================
-- マルチ同期
--===================================================================================================================
---------------------------------------------------------------------------------
-- receive6（獄門ゲージの数値同期）
---------------------------------------------------------------------------------
function class:receive6(args)
    local gaugeType = math.floor(args.arg / 100000);
    local value = args.arg % 100000;
    if gaugeType == 2 then
        self.bloodDamage = value;
    elseif gaugeType == 3 then
        self.curseDamage = value;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive7（ゲージ破壊通知）
---------------------------------------------------------------------------------
function class:receive7(args)
    local gaugeType = math.floor(args.arg / 100000);
    local sec = args.arg % 100000;
    if gaugeType == 1 then
        self:breakGirisuGauge(self.gameUnit);
    elseif gaugeType == 2 then
        self.gateElapsed = sec;                 ---ホストの経過秒数に合わせてから破壊処理を走らせる
        self:breakBloodGate(self.gameUnit);
    elseif gaugeType == 3 then
        self.gateElapsed = sec;
        self:breakCurseGate(self.gameUnit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive8（物理／魔法耐性の種別同期）
---------------------------------------------------------------------------------
function class:receive8(args)
    local triggerIndex = math.floor(args.arg / 10);
    local resistType = args.arg % 10;
    self:applyResistBuff(triggerIndex,resistType);
    return 1;
end

---------------------------------------------------------------------------------
-- receive9（気絶→ピヨリ移行の同期）
---------------------------------------------------------------------------------
function class:receive9(args)
    self:startPiyori(self.gameUnit);
    return 1;
end

---------------------------------------------------------------------------------
-- receive10（装備ダメージによるタイマー遅延の同期）
---------------------------------------------------------------------------------
function class:receive10(args)
    self:startTimerDelay();
    return 1;
end


--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return;
    end
    self:execShowMessage(messageBoxList[index]);
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox);
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i]);
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

---「〇体撃破！」のように数値を埋め込むメッセージ用
function class:showCountMessage(messageBox,count)
    local msg = string.format(messageBox.MESSAGE,count);
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(msg,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(msg,messageBox.DURATION,messageBox.COLOR);
    end
end


--===================================================================================================================
--トリガー
--===================================================================================================================
function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
end


--===================================================================================================================
-- バフ
--===================================================================================================================
-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:removeBuff(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
end

function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox);
        end
    end
end


--===================================================================================================================
-- 行動パターン
--===================================================================================================================
function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end


--===================================================================================================================
-- 状態異常除去
--===================================================================================================================
---トリガー時停止系状態異常除去（HPギミックが状態異常で発動できないことを防ぐ）---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end

---HPトリガー時の全状態異常回復（仕様書に「状態異常を回復」とある場合に使用）---
function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,135};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end


class:publish();

return class;
