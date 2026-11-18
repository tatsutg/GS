local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_HARD_焔巨砦ゴルマーグ", version=2.8, id=2064615});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    ---スキル1 -> スキル2 -> (スキル5 or スキル1 or スキル2) -> (スキル1 or スキル2) -> (スキル1 or スキル2) -> スキル5 -> 繰り返し
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK5 = 50, ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK5 = 100 },
    },
    ---エクストラゲージ表示中：スキル4 -> 繰り返し
    EXTRA = {
        { ATTACK4 = 100 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    ---奥義9 -> 繰り返し
    DEFAULT = {
        { SKILL2 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---踏みつけ       (attack1)
    ATTACK2 = 2,    ---アッパー       (attack2)
    ATTACK3 = 3,    ---ハンマー抜刀   (attack3／HPフラグで1回だけ割り込ませる)
    ATTACK4 = 4,    ---ハンマー攻撃   (attack4)
    ATTACK5 = 5,    ---掴み           (attack5)
    ATTACK6 = 6,    ---投擲物         (goblin_ax／bone／iron-ball のオービット)
    ATTACK7 = 7,    ---毒瓶           (goblin_poison のオービット)
    ATTACK8 = 8,    ---掴み投げ       (掴みの throwEnd で当てる)
    SKILL2  = 9,    ---飛びかかる     (skill2)
    SKILL3  = 10,   ---飛びかかる・強 (skill2のアニメを流用／一騎打ち失敗時)
}

class.cutInSkill = {
}


---掴み投げで使うボーン
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

---投擲物・毒瓶のオービット
class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 6
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 6
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 6
    },
    POIZON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 7
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}

---掴み中の拘束用（掴まれたユニットを毎フレーム気絶させる）
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;

---属性名（0=無 1=炎 2=水 3=樹 4=光 5=闇）
class.ELEMENT_NAMES = { [1]="炎", [2]="水", [3]="樹", [4]="光", [5]="闇" };
---性質名（1=物理 2=魔法）
class.TYPE_NAMES = { [1]="物理", [2]="魔法" };


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ターゲットに対してクリティカル率アップ（対象の被クリティカル率を上げる）
    self.TARGET_BUFF_LIST1 = {
        ID = 206461501,
        BUFF_ID = 23,                       ---被クリティカル率
        VALUE = self.GD.targetCritRate,
        DURATION = 999999,
        ICON = 0                            ---ターゲットギミックのバフはアイコン不要
    };
    self.TARGET_BUFF_LIST0 = {
        ID = 206461501,                     ---TARGET_BUFF_LIST1と同じIDで打ち消す
        BUFF_ID = 23,
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    };

    ---タイマー1周ごとの与ダメージアップ
    self.TG_BUFF_LIST = {
        [1] = {
            ID = 206461502,
            BUFF_ID = 17,                   ---与ダメージ
            VALUE = self.GD.tgBuffVal_17,
            DURATION = 999999,
            ICON = 26,
            MAX = self.GD.tgBuffMax,        ---重複＆アイコンに数字表示
        },
    };

    ---クリティカルダメージアップ（HP60%／HP30%で重複）
    self.CRIT_DMG_BUFF_LIST = {
        [1] = {
            ID = 206461503,
            BUFF_ID = 17,                   ---与ダメージ
            VALUE = self.GD.critDmgUpVal,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = { SCRIPT_ID = 22 },    ---クリティカルダメージ専用
            MAX = self.GD.critDmgUpMax,
        },
    };

    ---一騎打ち中、ターゲット以外を気絶させる
    self.DUEL_STUN_BUFF_LIST = {
        [1] = {
            ID = 206461504,
            BUFF_ID = 89,                   ---気絶
            VALUE = 100,
            DURATION = 999999,              ---ゲージ終了時に手動で除去する
            ICON = 0,
        },
    };

    ---一騎打ち勝利時のボスの気絶
    self.BOSS_STUN_BUFF_LIST = {
        [1] = {
            ID = 206461505,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = self.GD.bossStunTime,
            ICON = 0,
        },
    };

    ---一騎打ち中、ターゲットに奥義ゲージ自然上昇
    self.DUEL_SP_BUFF_LIST = {
        [1] = {
            ID = 206461506,
            BUFF_ID = 10,                   ---奥義ゲージ自然上昇
            VALUE = self.GD.duelSpGain,
            DURATION = 999999,              ---ゲージ終了時に手動で除去する
            ICON = 36,                      ---奥義ゲージ自然上昇（213は自然減少なので不可）
        },
    };

    ---性質（物理／魔法）耐性　[1]=物理 [2]=魔法
    self.RESIST_TYPE_BUFF_LIST = {
        [1] = {
            ID = 206461507,
            BUFF_ID = 21,                   ---被ダメージ（負値＝軽減）
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 21,                      ---物理耐性
            SCRIPT = { SCRIPT_ID = 2 },     ---受けるダメージが物理のとき
        },
        [2] = {
            ID = 206461508,
            BUFF_ID = 21,
            VALUE = self.GD.resistVal_21,
            DURATION = 999999,
            ICON = 22,                      ---魔法耐性
            SCRIPT = { SCRIPT_ID = 3 },     ---受けるダメージが魔法のとき
        },
    };

    ---属性耐性（効果は takeDamageValue で掛けるのでアイコン表示専用）
    self.RESIST_ELEMENT_BUFF_LIST = {
        [1] = { ID = 206461509, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 38 },  ---炎耐性
        [2] = { ID = 206461509, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 39 },  ---水耐性
        [3] = { ID = 206461509, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 40 },  ---樹耐性
        [4] = { ID = 206461509, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 41 },  ---光耐性
        [5] = { ID = 206461509, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 42 },  ---闇耐性
    };
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "リーダーに対してターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットしたユニットに対してCRI率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間経過でダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "CRIダメージで一定時間遅延", COLOR = Color.yellow}),
    }

    ---HP60%
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "行動速度アップ・CRIダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE2 or "飛びかかるを止めろ！！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE3 or "一騎打ち勝利で阻止", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE4 or "一騎打ち中CRIダメージ反射", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE5 or "庇っているユニットのダメージアップ", COLOR = Color.yellow, isPlayer = true}),
    }
    self.HP60_CLEAR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_CLEAR_MESSAGE1 or "一騎打ち勝利！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_CLEAR_MESSAGE2 or "ゴルマーグ：気絶状態", COLOR = Color.red}),
    }
    self.HP60_FAILED_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_FAILED_MESSAGE1 or "飛びかかる・強：庇う無効・無効化無効", COLOR = Color.red}),
    }

    ---HP30%
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義ゲージ上昇量アップ・CRIダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "飛びかかるを止めろ！！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE3 or "一騎打ち勝利で阻止", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE4 or "一騎打ち中CRIダメージ反射", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE5 or "庇っているユニットのダメージアップ", COLOR = Color.yellow, isPlayer = true}),
    }
    self.HP30_CLEAR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_CLEAR_MESSAGE1 or "一騎打ち勝利！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_CLEAR_MESSAGE2 or "ゴルマーグ：気絶状態", COLOR = Color.red}),
    }
    self.HP30_FAILED_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_FAILED_MESSAGE1 or "飛びかかる・強：庇う無効・無効化無効", COLOR = Color.red}),
    }

    ---耐性アップ（%sに性質名／属性名が入る）
    self.RESIST_TYPE_MESSAGE = self:setMessageInfo({MESSAGE = self.TEXT.RESIST_TYPE_MESSAGE1 or "累計ダメージの大きい%s耐性アップ", COLOR = Color.yellow});
    self.RESIST_ELEMENT_MESSAGE = self:setMessageInfo({MESSAGE = self.TEXT.RESIST_ELEMENT_MESSAGE1 or "累計ダメージの大きい%s属性耐性アップ", COLOR = Color.yellow});

    ---一騎打ちのトリガー番号 → メッセージ
    self.DUEL_CLEAR_MESSAGE_LIST = {
        [1] = self.HP60_CLEAR_MESSAGE_LIST,
        [2] = self.HP30_CLEAR_MESSAGE_LIST,
    };
    self.DUEL_FAILED_MESSAGE_LIST = {
        [1] = self.HP60_FAILED_MESSAGE_LIST,
        [2] = self.HP30_FAILED_MESSAGE_LIST,
    };
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
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

function class:hp60(status)
    if status == "use3" then
        self:refresh(self.gameUnit);                                ---停止系状態異常除去
        self.hpSkillFLG = true;                                     ---打ち終わるまでブレイク不可
        self.gameUnit:setAttackDelay(self.GD.hp60AttackDelay);      ---行動速度アップ
        self:execAddBuff(self.gameUnit,self.CRIT_DMG_BUFF_LIST[1]); ---クリティカルダメージアップ
        self:showMessage(self.HP60_MESSAGE_LIST);
        self.hummerAttackIndex = 3;                                 ---スキル3 ハンマー抜刀を割り込ませる
        self:getRage(self.gameUnit);                                ---行動パターン変化（ハンマー状態）
        self:reserveDuel(1,self.GD.exGaugeHP60);
    end
end

function class:hp30(status)
    if status == "use3" then
        self:refresh(self.gameUnit);
        self.hpSkillFLG = true;
        self.spValue = self.GD.hp30AddSP;                           ---奥義ゲージ上昇量アップ
        self:execAddBuff(self.gameUnit,self.CRIT_DMG_BUFF_LIST[1]);
        self:showMessage(self.HP30_MESSAGE_LIST);
        self.hummerAttackIndex = 3;
        self:getRage(self.gameUnit);
        self:reserveDuel(2,self.GD.exGaugeHP30);
    end
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 25,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 8,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---ターゲットギミック
        targetCritRate = 50,        --ターゲットに対するクリティカル率アップ%（被クリティカル率）

        ---タイマーギミック
        tgTimer = 15,               --1周の秒数
        tgLimit = 99,               --ループ上限
        tgIconNum1 = 26,            --タイマーのアイコン番号（与ダメージアップ。27は与ダメージダウン）
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgBuffVal_17 = 20,          --1周ごとの与ダメージアップ%
        tgBuffMax = 99,             --重複上限（アイコンの数字）
        tgDelayTime = 3,            --クリティカルダメージによる遅延秒数
        tgDelaySpeed = 0.333,       --遅延中のタイマー速度（1/3）

        ---HPフラグ
        hp60AttackDelay = 4,        --HP60%以降のアタックディレイ
        hp30AddSP = 35,             --HP30%以降のSP獲得量
        critDmgUpVal = 50,          --クリティカルダメージアップ%（HPフラグ毎）
        critDmgUpMax = 2,           --HP60%／HP30%の2回ぶんの重複上限

        ---一騎打ち（エクストラゲージ）
        exGaugeHP60 = 15000000,     --HP60%のエクストラゲージHP
        exGaugeHP30 = 25000000,     --HP30%のエクストラゲージHP
        duelReflectRate = 0.05,     --クリティカルダメージの反射率
        duelSpGain = 10,            --一騎打ち中ターゲットに付与する奥義ゲージ自然上昇
        bossStunTime = 5,           --一騎打ち勝利時のボスの気絶秒数
        duelStartTimeout = 10,      --ハンマー抜刀が発動しない場合に一騎打ちを強制開始するまでの秒数
        duelCoverRate = 3,          --庇っているユニットからのダメージがエクストラゲージへ入る倍率
        subBarPosY = 0,             --サブバーの表示位置（ボス座標からのオフセットY）

        ---属性・性質耐性
        resistVal_21 = -50,         --性質（物理／魔法）耐性の被ダメージ軽減%
        resistElementRate = 0.5,    --属性耐性の被ダメージ倍率

        ---掴み＆掴み投げ
        throwDownBP = 150,          --掴み投げの奥義ゲージDOWN量
        throwFixDmgBase = 3000,     --掴み投げの固定ダメージ（基礎）
        throwFixDmgAdd = 1000,      --掴み投げの固定ダメージ（掴み回数ごとの加算）

        ---投射物（スキル6 投擲物 → スキル7 毒瓶 → 繰り返し）
        grenadeRecast = 8,          --投射の間隔秒数
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
    self.afterSkillFLG = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---ターゲットギミック（自動ヘイトは使わない）
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetIndex = -1;

    ---タイマーギミック（戦闘開始から動作）
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(
        self.GD.tgTimer, self.GD.tgLimit,
        self.GD.tgIconNum1, self.GD.tgIconNum2,
        self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.tgDelayTime = 0;               ---クリティカルダメージによる遅延の残り秒数

    ---一騎打ち（エクストラゲージ）
    self.duelFLG = false;
    self.duelReserve = 0;               ---ハンマー抜刀待ちのトリガー番号（0=なし）
    self.duelReserveHP = 0;
    self.duelReserveTime = 0;
    self.duelIndex = 0;                 ---1=HP60% 2=HP30%
    self.duelTargetIndex = -1;
    self.duelDamage = 0;
    self.duelSentDamage = -1;           ---ゲージ同期で最後に送った値（1000ダメージ単位）
    self.SUB_HP = self.GD.exGaugeHP60;

    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200);          ---バーの全体の長さを指定
    self.subBar:setHeight(13);          ---バーの幅を指定
    self.subBar:setPercent(0);          ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBar:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
    self.subBar:setBarColor(255,153,0);

    ---属性・性質の累計ダメージ
    self.physicalDamage = 0;
    self.magicDamage = 0;
    self.elementDamage = {};
    self.resistAttribute = 0;           ---1=物理 2=魔法
    self.resistElement = 0;             ---1..5

    ---掴み関連
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    self.glabCount = 0;
    self.attackFlg = false;

    ---投射物関連
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    self.grenadeTurn = 1;               ---次に投げるもの（1=スキル6 投擲物 / 2=スキル7 毒瓶）
    self.grenadeKind = 1;               ---今のアニメで投げるもの
    self.grenadeFired = true;           ---1アニメで1回だけ発射するためのフラグ

    ---武器状態
    self.state = self.WEAPON_STATES.NONE;
    self.isRage = false;
    self.hummerAttackIndex = nil;

    event.unit:addSubSkeleton("50003_leg",-30);
    event.unit:setSkin("1");
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---開幕はリーダーユニットをターゲットする
    self:targetOperation(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---ターゲットギミック（一騎打ち中・予約中はターゲットを固定する）
    if not self:isDuelActive() then
        self:targetOperation(event.unit);
    end

    ---ハンマー抜刀が何らかの理由で発動しない場合の保険（気絶が残り続けるのを防ぐ）
    if self.duelReserve ~= 0 then
        self.duelReserveTime = self.duelReserveTime + event.deltaTime;
        if self.duelReserveTime > self.GD.duelStartTimeout then
            self:startDuel();
        end
    end

    ---タイマーギミック
    self:extraTimerOperation(event.unit);
    if self.tgDelayTime > 0 then
        self.tgDelayTime = self.tgDelayTime - event.deltaTime;
        if self.tgDelayTime < 0 then self.tgDelayTime = 0; end
    end

    ---一騎打ち（エクストラゲージ）
    if self.duelFLG then
        self:duelGaugeControll(event.unit);
    end

    ---掴み投げ
    if self.isGlab and self.glabTargetIndex ~= nil then
        ---掴み中に奥義が発生した場合の対策
        if event.unit:getUnitState() == kUnitState_skill then
            self:throwEnd(event.unit);
        else
            self:glabControll(event.unit);
        end
    end

    ---投擲物・毒瓶
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end


--===================================================================================================================
-- ターゲットギミック
--===================================================================================================================
---開幕はリーダー。ターゲットしたユニットが倒れた場合は一番左のユニット
function class:checkTargetUnit()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = nil;
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            target = u;
            break;
        end
    end
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getIsLeader() then
            return u;
        end
    end
    return target;
end

---ヘイトは全部手動で設定する（ホストが決めてゲストへ配る）
function class:targetOperation(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    local target = self:checkTargetUnit();
    if target == nil then
        return;
    end
    if target:getIndex() ~= self.targetIndex then
        self:applyTarget(target:getIndex());
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,target:getIndex());
    end
    unit:setHateTarget(target);
    unit:updateHateTarget();
end

function class:applyTarget(index)
    self.targetIndex = index;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == index then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
            end
        end
    end
end


--===================================================================================================================
-- タイマーギミック
--===================================================================================================================
---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        self:execAddBuff(event.unit,self.TG_BUFF_LIST[1]);      ---ボスへ与ダメージアップ
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex == nil then
        return;
    end
    local speed = 1;
    ---ブレイク中・無敵中・HPフラグ奥義中・エクストラゲージ表示中は停止
    if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG or self.duelFLG then
        speed = 0;
    elseif self.tgDelayTime > 0 then
        speed = self.GD.tgDelaySpeed;                           ---クリティカルダメージによる遅延
    end
    if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex,speed);
    end
    self.timeSpeed = speed;
end

function class:startTimerDelay()
    self.tgDelayTime = self.GD.tgDelayTime;
end

function class:removeTimers()
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil;
    end
end


--===================================================================================================================
-- 一騎打ち（エクストラゲージ）
--===================================================================================================================
---HPフラグ時点では「気絶」までを行い、エクストラゲージとクリティカル反射は
---ハンマー抜刀が実際に発動する takeAttack(ATTACK3) まで遅らせる。
---HPフラグと同時に反射を有効化すると、気絶が効く前に飛行中のクリティカルが反射されて
---ユニットが倒れてしまうため（実機で発生）。
function class:reserveDuel(triggerIndex,gaugeHP)
    ---掴みの最中にHPフラグへ到達した場合は掴みを中断する。
    ---中断しないと throwEnd が成立し、固定ダメージでユニットが倒れてしまう
    self:releaseGlab(self.gameUnit);
    self.duelReserve = triggerIndex;
    self.duelReserveHP = gaugeHP;
    self.duelReserveTime = 0;
    self.duelTargetIndex = self.targetIndex;

    ---ハンマー抜刀によりターゲット以外を気絶状態にする（反射より先に止める）
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and i ~= self.duelTargetIndex then
            self:execAddBuff(u,self.DUEL_STUN_BUFF_LIST[1]);
        end
    end
end

---ハンマー抜刀の発動に合わせてエクストラゲージを表示し、クリティカル反射を有効化する
function class:startDuel()
    if self.duelReserve == 0 then
        return;
    end
    self.duelIndex = self.duelReserve;
    self.duelReserve = 0;
    self.duelFLG = true;
    self.duelDamage = 0;
    self.duelSentDamage = -1;
    self.SUB_HP = self.duelReserveHP;

    ---エクストラゲージ表示中、ターゲットに奥義ゲージ自然上昇
    local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.duelTargetIndex);
    if target ~= nil then
        self:execAddBuff(target,self.DUEL_SP_BUFF_LIST[1]);
    end
end

---庇っているユニットか
---※状態タイプ128は「庇われている側」が持ち、getProtectTarget() が「庇っている側」のindexを返す
function class:isCoverUnit(unit)
    local index = unit:getIndex();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            local cond = u:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil and cond:getProtectTarget() == index then
                return true;
            end
        end
    end
    return false;
end

---一騎打ちの予約中か開始済みか（どちらもボスへのダメージは1にする）
function class:isDuelActive()
    return self.duelFLG or self.duelReserve ~= 0;
end

function class:duelGaugeControll(unit)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY() + self.GD.subBarPosY);
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - self.duelDamage) / self.SUB_HP);

    ---終了判定はホストのみ
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    ---一騎打ち対象のユニットが倒された場合は失敗
    if megast.Battle:getInstance():getTeam(true):getTeamUnit(self.duelTargetIndex) == nil then
        self:sendDuelEnd(false);
        return;
    end
    ---削り切りで勝利
    if self.SUB_HP - self.duelDamage <= 0 then
        self:sendDuelEnd(true);
    end
end

---累計ダメージから耐性の種別を決める（HP60%＝性質 HP30%＝属性）
function class:calcResistType()
    if self.duelIndex == 1 then
        ---クリティカルダメージは skillAttribute==3 になり物理／魔法のどちらにも積算されない。
        ---全てクリティカルなどで性質が判定できなかった場合は魔法耐性にする
        if self.physicalDamage == 0 and self.magicDamage == 0 then
            return 2;
        end
        return self.magicDamage > self.physicalDamage and 2 or 1;
    end
    local maxDmg = 0;
    local maxID = 0;
    for id,dmg in pairs(self.elementDamage) do
        if dmg > maxDmg then
            maxDmg = dmg;
            maxID = id;
        end
    end
    return maxID;
end

function class:sendDuelEnd(success)
    local resistType = self:calcResistType();
    local result = success and 1 or 2;
    self:finishDuel(success,resistType);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,8,result * 100 + resistType);
end

function class:finishDuel(success,resistType)
    if not self.duelFLG then
        return;
    end
    self.duelFLG = false;
    self.duelReserve = 0;
    self.subBar:setVisible(false);
    self:endRage(self.gameUnit);                        ---行動パターンを戻す

    ---奥義ゲージ自然上昇を終了・ターゲット以外の気絶を回復
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            self:removeBuff(u,self.DUEL_SP_BUFF_LIST[1].ID);
            self:removeBuff(u,self.DUEL_STUN_BUFF_LIST[1].ID);
        end
    end

    if success then
        self:showMessage(self.DUEL_CLEAR_MESSAGE_LIST[self.duelIndex]);
        self:execAddBuff(self.gameUnit,self.BOSS_STUN_BUFF_LIST[1]);    ---ボスは5秒間、気絶状態
    else
        self:showMessage(self.DUEL_FAILED_MESSAGE_LIST[self.duelIndex]);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                           ---奥義10 飛びかかる・強
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
    end

    ---破壊・破壊失敗のどちらでも耐性ギミックが確定する
    self:applyDuelResist(self.duelIndex,resistType);
end

function class:applyDuelResist(duelIndex,resistType)
    if duelIndex == 1 then
        ---性質（物理／魔法）耐性
        if self.RESIST_TYPE_BUFF_LIST[resistType] ~= nil then
            self.resistAttribute = resistType;
            self:execAddBuff(self.gameUnit,self.RESIST_TYPE_BUFF_LIST[resistType]);
            self:showFormatMessage(self.RESIST_TYPE_MESSAGE,self.TYPE_NAMES[resistType]);
        end
        ---HP30%用の属性累計はここから数え直す（累計60%〜30%）
        self.physicalDamage = 0;
        self.magicDamage = 0;
        self.elementDamage = {};
    else
        ---属性耐性（HP60%の補正と重複した場合は乗算になる）
        if self.RESIST_ELEMENT_BUFF_LIST[resistType] ~= nil then
            self.resistElement = resistType;
            self:execAddBuff(self.gameUnit,self.RESIST_ELEMENT_BUFF_LIST[resistType]);
            self:showFormatMessage(self.RESIST_ELEMENT_MESSAGE,self.ELEMENT_NAMES[resistType]);
        end
    end
end

---一騎打ち関連のバフを掃除する（ボス撃破時の保険）
function class:clearDuelBuffs()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            self:removeBuff(u,self.DUEL_SP_BUFF_LIST[1].ID);
            self:removeBuff(u,self.DUEL_STUN_BUFF_LIST[1].ID);
        end
    end
end


--===================================================================================================================
-- ハンマー状態
--===================================================================================================================
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    self.isRage = true;
    unit:setSetupAnimationName("setUpWeapon");
    unit:setSkin("1");
    self:initAttackWeight({EXTRA = 100});               ---スキル4 ハンマー攻撃のみ
end

function class:endRage(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.isRage = false;
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setSkin("2");
    self:initAttackWeight({DEFAULT = 100});
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end

    ---投射のSpineイベント。ゴルマーグ(50003)のスピンは goblinAttack を飛ばす。
    ---lunchPoisonGrenade / lunchOther はジオ＝ザグナス(50103)側のイベント名で
    ---ゴルマーグでは飛んでこないが、保険として同じ処理へ繋いでおく
    if event.spineEvent == "goblinAttack" then self:lunchByTurn(event.unit); end

    if event.spineEvent == "glab" then self:glab(event.unit); end
    if event.spineEvent == "throw" then self:throw(event.unit); end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit); end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit); end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit); end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit); end
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

    ---掴み攻撃時のaddSP用
    if event.index == 5 then
        self.attackFlg = true;
    end

    ---ハンマー抜刀の発動に合わせて一騎打ちを開始する（気絶を効かせてから反射を有効化する）
    if event.index == 3 then
        self:startDuel();
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---ハンマー抜刀（HPフラグで1回だけ割り込ませる）
    if self.hummerAttackIndex ~= nil then
        attackIndex = self.hummerAttackIndex;
        self.hummerAttackIndex = nil;
    end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
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

    ---奥義10（飛びかかる・強）は奥義9と同じ skill2 アニメを使う
    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill2");
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.cutInFLG = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
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
    ---掴みが当たった時点でターゲット以外の最大奥義ゲージのユニットを選ぶ
    if self.tryGlab and self.glabTargetIndex == nil then
        self.glabTargetIndex = self:checkGlabTarget();
        self:checkGlabSucsess(event.unit);
    end
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
    local info = enemyUnit:getTeamUnitCondition():getDamageAffectInfo();
    local isCritical = info.critical or info.skillAttribute == 3;

    ---① 累計ダメージを集計（性質＝物理／魔法・属性＝攻撃したユニットの属性）
    if megast.Battle:getInstance():isHost() then
        if info.skillAttribute == 1 then
            self.physicalDamage = self.physicalDamage + event.value;
        elseif info.skillAttribute == 2 then
            self.magicDamage = self.magicDamage + event.value;
        end
        local element = enemyUnit:getElementType();
        if element ~= nil and element > 0 then
            self.elementDamage[element] = (self.elementDamage[element] or 0) + event.value;
        end
    end

    ---② クリティカルダメージでタイマーを遅延させる（遅延中は重複しない）
    if isCritical and self.timeIndex ~= nil and self.tgDelayTime <= 0
    and megast.Battle:getInstance():isHost() then
        self:startTimerDelay();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
    end

    ---③ 一騎打ち中（ハンマー抜刀の予約中もボスへのダメージは1にして、HPフラグの飛び越しを防ぐ）
    if self:isDuelActive() then
        ---エクストラゲージはクリティカルダメージを反射する（ゲージ表示後のみ）
        if self.duelFLG and isCritical and enemyUnit:getHP() > 0 then
            local reflect = math.floor(event.value * self.GD.duelReflectRate);
            if reflect > 0 then
                enemyUnit:setHP(enemyUnit:getHP() - reflect);
            end
        end
        ---エクストラゲージへダメージを蓄積（ホストのみ・ゲストへ配る）
        ---1000ダメージ単位で値が変わったときだけ送る（多段HITで送信が溢れないように）
        if self.duelFLG and megast.Battle:getInstance():isHost() then
            local gaugeValue = event.value;
            ---庇っているユニットからのダメージはゲージに倍率で入る
            if self:isCoverUnit(enemyUnit) then
                gaugeValue = math.floor(gaugeValue * self.GD.duelCoverRate);
            end
            self.duelDamage = self.duelDamage + gaugeValue;
            local sendValue = math.floor(self.duelDamage / 1000);
            if sendValue ~= self.duelSentDamage then
                self.duelSentDamage = sendValue;
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,sendValue);
            end
        end
        ---エクストラゲージ表示中ボスは全てのダメージに対して1にする
        event.value = 1;
        event.value = self:adjustHpFlg(event.unit,event.value);
        return event.value;
    end

    ---④ 属性耐性（性質耐性はバフ側で処理する。重複した場合は乗算になる）
    if self.resistElement ~= 0 and enemyUnit:getElementType() == self.resistElement then
        event.value = math.floor(event.value * self.GD.resistElementRate);
    end

    ---⑤ HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないため属性・クリティカルの判定はできない）
-- 性質耐性はバフ（BUFF_ID=21+SCRIPT_ID=2/3）なのでエンジン側が適用する
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    elseif self:isDuelActive() then
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
    ---HPフラグは発動から打ち終わるまでブレイク不可
    if self.hpSkillFLG then
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

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.isRage then
        event.unit:setNextAnimationName("idle2");
    end
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0);
        end
        ---HPフラグの発動はハンマー抜刀（通常攻撃）なので afterSkillFLG が立たない。
        ---アイドルへ戻った時点で「打ち終わった」とみなしてブレイク不可を解除する
        self.hpSkillFLG = false;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:removeTimers();
    self:clearDuelBuffs();
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
    self:removeTimers();
    self:clearDuelBuffs();
    return 1;
end


--===================================================================================================================
-- 掴み＆掴み投げ
--===================================================================================================================
function class:glab(unit)
    ---一騎打ち中は掴みを発動しない
    if self:isDuelActive() then
        return;
    end
    self.tryGlab = true;
end

---掴みを中断してユニットを解放する（固定ダメージ・掴み回数の加算はしない）
function class:releaseGlab(unit)
    self.tryGlab = false;
    if not self.isGlab then
        self.glabTargetIndex = nil;
        return;
    end
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end
    ---掴み中に動かした表示状態を戻す
    glabUnit:getSkeleton():setPosition(0,0);
    glabUnit._autoZorder = true;
end

---ターゲット以外で一番奥義ゲージの多いユニット。ターゲットしかいない場合はターゲット
function class:checkGlabTarget()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local index = nil;
    local bp = -1;
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and i ~= self.targetIndex then
            if u:getBurstPoint() > bp then
                bp = u:getBurstPoint();
                index = i;
            end
        end
    end
    if index == nil and myTeam:getTeamUnit(self.targetIndex) ~= nil then
        index = self.targetIndex;
    end
    return index;
end

function class:checkGlabSucsess(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,10,100 + self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,10,200);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    local glabUnit = self:getUnitByIndex(index);
    if glabUnit ~= nil then
        glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFVALUE,self.STAN_BUFFEFDURATION,0);
    end
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
    ---一騎打ち中は掴み投げを成立させない（HPフラグ直後にSpineイベントが飛んでくるケースの保険）
    if self:isDuelActive() then
        self:releaseGlab(unit);
        return;
    end
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end

    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);
    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(8);                              ---スキル8 掴み投げ

    ---奥義ゲージDOWN＆固定ダメージ[base + add × 掴み回数]
    local fixDmg = self.GD.throwFixDmgBase + self.GD.throwFixDmgAdd * self.glabCount;
    self.glabCount = self.glabCount + 1;
    glabUnit:setBurstPoint(glabUnit:getBurstPoint() - self.GD.throwDownBP);
    local artsHpBefore = glabUnit:getHP()
    glabUnit:setHP(glabUnit:getHP() - fixDmg);
    -- 【MEGA_D-9756】メッセージログで、この技の行に減った HP を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
    if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
        megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, glabUnit, artsHpBefore - glabUnit:getHP())
    end

    ---掴み攻撃でaddSPする用
    if self.attackFlg then
        self.attackFlg = false;
        self:addSP(self.gameUnit);
    end
end

function class:glabFaild(unit)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end
    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFVALUE,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end


--===================================================================================================================
-- 投擲物・毒瓶
--===================================================================================================================
-- 行動パターンとは別枠で grenadeRecast 秒ごとに
-- スキル6（投擲物・中身はランダム）→ スキル7（毒瓶）→ 繰り返し で投げる。
-- ゴルマーグのスピンには goblin_attack2 が無く投げ分けのアニメが1本しかないため、
-- 何を投げるかはSpineイベント任せにせずLua側の順番で決める。
function class:grenadeCheck(deltaTime)
    ---一騎打ち中は投射しない（行動パターンがスキル4のみになるため）
    if self:isDuelActive() then
        return;
    end
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast then
        self.grenadeTimer = 0;
        if megast.Battle:getInstance():isHost() then
            self:takeGrenadeAnimation(self.gameUnit,self.grenadeTurn);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,10,300 + self.grenadeTurn);
            ---次は反対側を投げる
            self.grenadeTurn = self.grenadeTurn == 1 and 2 or 1;
        end
    end
end

function class:takeGrenadeAnimation(unit,turn)
    self.grenadeKind = turn;
    self.grenadeFired = false;
    unit:setAnimation(1,"goblin_attack",false);
end

---Spineイベントは lunchPoisonGrenade / lunchOther のどちらが飛んできても
---現在の順番に従って投げる（両方飛んできても2重発射しない）
function class:lunchByTurn(unit)
    if self.grenadeFired then
        return;
    end
    self.grenadeFired = true;
    if self.grenadeKind == 2 then
        ---スキル7 毒瓶
        self:lunch(unit,self.ORBIT_ARGS.POIZON);
        return;
    end
    ---スキル6 投擲物（中身はランダム）
    local rand = LuaUtilities.rand(0,100);
    local arg = self.ORBIT_ARGS.IRON;
    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    end
    self:lunch(unit,arg);
end

function class:lunchPoisonGrenade(unit)
    self:lunchByTurn(unit);
end

function class:lunchOther(unit)
    self:lunchByTurn(unit);
end

function class:lunch(unit,arg)
    if unit:getHP() <= 0 then
        return;
    end
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:takeAnimation(0,arg.start,true);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:getTeamUnitCondition():addCondition(-12,35,0,25,0);
    bullet:setActiveSkill(arg.activeSkill);

    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
    local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
    bullet:setPosition(x+xb,y+yb);

    local counter = 0;
    local tgt = nil;
    while counter < 4 and tgt == nil do
        counter = counter + 1;
        tgt = self:getUnitByIndex(self.granedeTargetIndex%4);
        self.granedeTargetIndex = self.granedeTargetIndex + 1;
    end

    local targetx = 0;
    local targety = 0;
    if tgt ~= nil then
        targetx = tgt:getAnimationPositionX();
        targety = tgt:getAnimationPositionY();
    end

    LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
end

function class:getUnitByIndex(index)
    if index == nil then
        return nil;
    end
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end


--===================================================================================================================
-- マルチ同期
--===================================================================================================================
---------------------------------------------------------------------------------
-- receive6（エクストラゲージのダメージ同期／1000ダメージ単位）
---------------------------------------------------------------------------------
function class:receive6(args)
    self.duelDamage = args.arg * 1000;
    return 1;
end

---------------------------------------------------------------------------------
-- receive7（ターゲットindexの同期）
---------------------------------------------------------------------------------
function class:receive7(args)
    self:applyTarget(args.arg);
    local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg);
    if u ~= nil then
        self.gameUnit:setHateTarget(u);
        self.gameUnit:updateHateTarget();
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive8（一騎打ちの終了通知＋耐性の種別）
---------------------------------------------------------------------------------
function class:receive8(args)
    local result = math.floor(args.arg / 100);
    local resistType = args.arg % 100;
    self:finishDuel(result == 1,resistType);
    return 1;
end

---------------------------------------------------------------------------------
-- receive9（クリティカルダメージによるタイマー遅延の同期）
---------------------------------------------------------------------------------
function class:receive9(args)
    self:startTimerDelay();
    return 1;
end

---------------------------------------------------------------------------------
-- receive10（掴み成功／掴み失敗／投擲アニメの同期）
---------------------------------------------------------------------------------
function class:receive10(args)
    local kind = math.floor(args.arg / 100);
    local value = args.arg % 100;
    if kind == 1 then
        self.glabTargetIndex = value;
        self:glabExecute(self.gameUnit,value);
    elseif kind == 2 then
        self:glabFaild(self.gameUnit);
    elseif kind == 3 then
        self:takeGrenadeAnimation(self.gameUnit,value);
    end
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

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
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
    return 1;
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
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
