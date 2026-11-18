--@additionalEnemy,600000148
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_VERY HARD_堕天神獣ジオ＝ザグナス", version=2.8, id=600000145});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    ---スキル1 -> (スキル1 or スキル2) -> スキル2 -> (スキル1 or スキル2) -> (スキル1 or スキル2) -> 繰り返し
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    },
    ---ハンマー抜刀時：スキル4 -> 繰り返し
    HUMMER = {
        { ATTACK4 = 100 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    ---奥義6 -> 奥義5 -> 奥義6 -> 奥義5 -> 奥義11 -> 繰り返し
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL1 = 100 },
        { SKILL2 = 100 },
        { SKILL1 = 100 },
        { SKILL4 = 100 }
    },
    ---ハンマー抜刀時：奥義10 -> 奥義5 -> 繰り返し
    HUMMER = {
        { SKILL3 = 100 },
        { SKILL1 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---踏みつけ       (attack1)
    ATTACK2 = 2,    ---アッパー       (attack2)
    ATTACK3 = 3,    ---ハンマー抜刀   (attack3／奥義11の後に1回だけ割り込ませる)
    ATTACK4 = 4,    ---ハンマー攻撃   (attack4)
    ATTACK7 = 7,    ---投射物         (goblin_ax／bone／iron-ball のオービット)
    ATTACK8 = 8,    ---毒瓶           (goblin_poison のオービット)
    SKILL1  = 5,    ---掴み           (attack5 のアニメを流用 → skill1_throw)
    SKILL2  = 6,    ---飛びかかる     (skill2)
    SKILL9  = 9,    ---掴み投げ       (掴みの throwEnd で当てるオービット)
    SKILL3  = 10,   ---飛びかかる     (skill2 のアニメを流用)
    SKILL4  = 11,   ---飛びかかる     (skill2 のアニメを流用)
}

class.cutInSkill = {
}

---難易度で有無が変わるギミック
class.USE_HUMMER = true;            ---奥義11の後のハンマー抜刀（HARD以上）
class.USE_FIRST_SUMMON = true;      ---初回のブルーゴブル召喚数を固定する（HARD以上）
class.SUMMON_ID = 600000148;        ---召喚するブルーゴブル

---掴み投げで使うボーン
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

---投射物・毒瓶のオービット
class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 7
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 7
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 7
    },
    POISON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    }
}

---ハンマー攻撃で即死させる氷結（氷結・上位氷結）
class.FREEZE_TYPES = { 96, 207 };


--------[[バフ]]--------
function class:setBuffBoxList()
    ---レイド共通ヘイト（狙われている間のボスの与ダメージアップ）
    self.RAID_TARGET_BUFF_LIST = {
        [1] = {
            ID = 600145001,
            BUFF_ID = 17,                       ---与ダメージ
            VALUE = self.GD.raidTargetDmgVal,
            DURATION = 999999,
            ICON = 26
        }
    }
    ---掴み中の拘束（掴まれたユニットを毎フレーム気絶させる）
    self.GLAB_BUFF_LIST = {
        [1] = {
            ID = -10,
            BUFF_ID = 89,                       ---気絶
            VALUE = 100,
            DURATION = 1,
            ICON = 0
        }
    }
    if self.USE_HUMMER then
        ---ハンマー状態の防御力アップ
        self.HUMMER_BUFF_LIST = {
            [1] = {
                ID = 600145002,
                BUFF_ID = 15,                   ---防御力
                VALUE = self.GD.hummerDefVal,
                DURATION = 999999,
                ICON = 5
            }
        }
        ---ハンマー破壊時のボスの気絶
        self.STUN_BUFF_LIST = {
            [1] = {
                ID = 600145003,
                BUFF_ID = 89,                   ---気絶
                VALUE = 100,
                DURATION = self.GD.hummerStunTime,
                ICON = 79
            }
        }
    end
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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "全体CRI率・防御無視無効", COLOR = Color.yellow})
    }
    ---レイド共通ヘイト
    self.RAID_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RAID_MESSAGE1 or "ボスに狙われている！", COLOR = Color.red, DURATION = 10})
    }
    ---レイド共通テロップ
    self.TELOP_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE1 or "ボスに狙われると被ダメージが増加します。"}),
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"}),
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"})
    }
    self.GLAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE1 or "掴み投げ：%dの固定ダメージ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE2 or "時間経過でダメージアップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE3 or "攻撃力の高いユニットをターゲット", COLOR = Color.red})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "クエックエックエッ！", COLOR = Color.cyan})
    }
    self.FIRST_SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FIRST_SUMMON_MESSAGE1 or "ブルーゴブルの数に応じて被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.FIRST_SUMMON_MESSAGE2 or "ブルーゴブル：毒・暗闇・病気・燃焼の時：被ダメージアップ", COLOR = Color.white})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "与ダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "毒状態のユニットに対してダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL4_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL4_MESSAGE1 or "この奥義中、呪い状態のユニットに対してダメージアップ", COLOR = Color.yellow})
    }
    self.HUMMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE1 or "ハンマー状態：防御力アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE2 or "一定ダメージまたはブレイクでハンマー破壊", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE3 or "氷結状態の相手に対してハンマー攻撃で即死攻撃", COLOR = Color.yellow})
    }
    self.HUMMER_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_BREAK_MESSAGE1 or "ハンマー破壊成功！ダメージ耐性・防御力アップ：解除！", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {};
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

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 25,                 --SP獲得量
        startAddSP = 100,           --戦闘開始時の奥義ゲージ量
        attackDelay = 5,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---レイド共通ヘイト（ボスに狙われている！）
        raidTargetRank = 3,         --ルーム内のこの順位以内で狙われる
        raidTargetPoint = 1000000,  --累計バトルポイントがこの値を超えたら狙われる
        raidTargetDmgVal = 30,      --狙われている間のボスの与ダメージアップ%
        telopSpan = 30,             --レイド共通テロップの間隔秒数

        ---掴み投げ（奥義5）
        throwDownBPRate = 1,        --奥義ゲージDOWN量（バトル経過秒数 × この値）
        throwDownBPMax = 300,       --奥義ゲージDOWN量の上限
        throwFixDmgRate = 60,       --固定ダメージ（バトル経過秒数 × この値）

        ---投射物（スキル7 投射物 → スキル8 毒瓶 → 繰り返し）
        grenadeRecast = 8,          --投射の間隔秒数

        ---ハンマー抜刀（奥義11の後）
        hummerHpRate = 0.2,         --エクストラゲージのHP（ボスの最大HPに対する割合）
        hummerDefVal = 500,         --ハンマー状態の防御力アップ%
        hummerStunTime = 5,         --ハンマー破壊時のボスの気絶秒数
        subBarPosYHummer = 25,      --エクストラゲージ（ハンマー）の表示位置（ボス座標からのオフセットY）

        ---ブルーゴブル召喚
        summonRecast = 20,          --召喚の間隔秒数
        summonFirstNum = 4,         --初回の召喚数
        summonMax = 6,              --場に出せる最大数
        summonTwoRate = 40,         --2体召喚する確率%（残りは1体）
        summonDmgCutRate = 0.15,    --ブルーゴブル1体ごとのボスの被ダメージ軽減率

        ---ワンパン対策
        onePunchDmg = 100000000,    --奥義11を強制発動するダメージ量（このバトルでボスに与えたダメージ）
        subBarPosYOnePunch = 0,     --エクストラゲージ（ワンパン対策）の表示位置（ボス座標からのオフセットY）
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

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.breakFlg = false;
    self.hpSkillFLG = false;

    ---レイド共通ヘイト
    self.isRaidTarget = false;
    self.telopTimer = 0;

    ---掴み投げ
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    self.throwFixDmg = 0;
    self.throwDownBP = 0;

    ---投射物
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    self.grenadeTurn = 1;               ---次に投げるもの（1=スキル7 投射物 / 2=スキル8 毒瓶）

    ---ハンマー抜刀
    self.isRage = false;
    self.hummerAttackIndex = nil;       ---奥義11の後に割り込ませるハンマー抜刀
    self.SUB_HP = 0;                    ---エクストラゲージのHP
    self.damage = 0;                    ---エクストラゲージへのダメージ
    if self.USE_HUMMER then
        self.subBar = BattleControl:get():createSubBar();
        self.subBar:setWidth(200);      ---バーの全体の長さを指定
        self.subBar:setHeight(13);      ---バーの幅を指定
        self.subBar:setPercent(0);      ---バーの残量を0%に指定
        self.subBar:setVisible(false);
        self.subBar:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
        self.subBar:setBarColor(255,153,0);
    end

    ---ブルーゴブル召喚
    self.summonTimer = 0;
    self.summonCount = 0;               ---召喚した回数
    self.friendCount = 0;               ---場にいるブルーゴブルの数

    ---ワンパン対策
    self.onePunchDamage = 0;            ---このバトルでボスに与えたダメージ
    self.onePunchBorder = self.GD.onePunchDmg;
    self.subBarOnePunch = BattleControl:get():createSubBar();
    self.subBarOnePunch:setWidth(200);
    self.subBarOnePunch:setHeight(13);
    self.subBarOnePunch:setPercent(100);
    self.subBarOnePunch:setVisible(false);
    self.subBarOnePunch:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
    self.subBarOnePunch:setBarColor(0,128,255);

    ---足
    self:setupLeg(event.unit);
    return 1;
end

---足。download_bundle は各IDの Lua から addSubSkeleton の zip を拾い親から引き継がないため、継承した子にも同じ関数を書く
function class:setupLeg(unit)
    unit:addSubSkeleton("50103_leg",-30);
    unit:setSkin("1");
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
        self:onePunchCheck(event.unit);
    end

    ---レイド共通テロップ
    if RaidControl:get() ~= nil then
        self:telop(event.deltaTime);
    end

    ---ブルーゴブル召喚
    self:findFriend();
    self:summonCheck(event.deltaTime);

    ---エクストラゲージ
    self:onePunchBarControll(event.unit);
    if self.isRage then
        self:subBarControll(event.unit);
    end

    ---掴み投げ（掴んでいる間は手に追従させる。奥義が中断されたら放す）
    if self.isGlab then
        if event.unit:isBreak() or event.unit:getUnitState() ~= kUnitState_skill then
            self:releaseGlab(event.unit);
        else
            self:glabControll(event.unit);
        end
    end

    ---投射物（奥義中は止める）
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if RaidControl:get() ~= nil then
        self:checkRaidTarget();
    end
    return 1;
end


--===================================================================================================================
-- レイド共通ヘイト
--===================================================================================================================
---ルーム内の順位と累計バトルポイントで狙われる。狙われている間はボスの与ダメージアップ
function class:checkRaidTarget()
    local isTarget = self:getIsRaidTarget();
    if not self.isRaidTarget and isTarget then
        self:execAddBuff(self.gameUnit,self.RAID_TARGET_BUFF_LIST[1]);
        self:showMessage(self.RAID_MESSAGE_LIST);
    end
    if isTarget then
        BattleControl:get():showHateAll();
    else
        BattleControl:get():hideHateAll();
        self:removeBuff(self.gameUnit,self.RAID_TARGET_BUFF_LIST[1].ID);
    end
    self.isRaidTarget = isTarget;
end

function class:getIsRaidTarget()
    return RaidControl:get():getRanking() <= self.GD.raidTargetRank and RaidControl:get():getTotalBattlePoint() > self.GD.raidTargetPoint;
end

function class:telop(deltaTime)
    self.telopTimer = self.telopTimer + deltaTime;
    if self.telopTimer < self.GD.telopSpan then
        return;
    end
    self.telopTimer = 0;
    local rand = LuaUtilities.rand(1,#self.TELOP_MESSAGE_LIST + 1);
    RaidControl:get():addPauseMessage(self.TELOP_MESSAGE_LIST[rand].MESSAGE,2.2);
end


--===================================================================================================================
-- ワンパン対策
--===================================================================================================================
-- レイドはボスのHPが他プレイヤーのダメージでも減るため、このバトルでボスに与えたダメージで数える。
---強制発動ラインに届く攻撃はラインで止め、奥義11を発動するまではダメージを1にする
function class:adjustOnePunch(unit,value)
    if unit:getInvincibleTime() > 0 then
        return value;
    end
    if self.onePunchDamage >= self.onePunchBorder then
        return 1;
    end
    if self.onePunchDamage + value >= self.onePunchBorder then
        value = self.onePunchBorder - self.onePunchDamage;
        self.breakSkip = true;
    end
    self.onePunchDamage = self.onePunchDamage + value;
    return value;
end

---ラインに届いたら奥義11を強制発動（ブレイク中は待つ。奥義ゲージ・奥義パターンは発動前を維持）
function class:onePunchCheck(unit)
    if self.onePunchDamage < self.onePunchBorder or self.hpSkill ~= 0 or unit:isBreak() then
        return;
    end
    self.onePunchBorder = self.onePunchBorder + self.GD.onePunchDmg;
    self:refresh(unit);
    self.hpSkill = 4;
    self.saveBP = unit:getBurstPoint();
    unit:addSP(100);
    unit:setInvincibleTime(20);
    self.hpSkillFLG = true;
end

---次の強制発動ラインまでの残りを表示
function class:onePunchBarControll(unit)
    local rest = self.onePunchBorder - self.onePunchDamage;
    if rest < 0 then
        rest = 0;
    end
    self.subBarOnePunch:setPositionX(unit:getPositionX());
    self.subBarOnePunch:setPositionY(unit:getPositionY() + self.GD.subBarPosYOnePunch);
    self.subBarOnePunch:setVisible(true);
    self.subBarOnePunch:setPercent(100 * rest / self.GD.onePunchDmg);
end


--===================================================================================================================
-- ハンマー状態
--===================================================================================================================
function class:getRage(unit)
    self.isRage = true;
    self.SUB_HP = unit:getCalcHPMAX() * self.GD.hummerHpRate;
    self.damage = 0;
    unit:setSetupAnimationName("setUpWeapon");
    self:initAttackWeight({HUMMER = 100});
    self:initSkillWeight({HUMMER = 100});
    self:execAddBuff(unit,self.HUMMER_BUFF_LIST[1]);
    self:showMessage(self.HUMMER_MESSAGE_LIST);
end

---エクストラゲージ（ハンマー）。削り切るとハンマー破壊
function class:subBarControll(unit)
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY() + self.GD.subBarPosYHummer);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.SUB_HP - self.damage) / self.SUB_HP);
    if self.SUB_HP - self.damage <= 0 then
        self:weaponBreak(unit);
    end
end

---ハンマー破壊：被ダメージ1と防御力アップを解除して気絶。奥義パターンは最初から
function class:weaponBreak(unit)
    self.isRage = false;
    self.subBar:setVisible(false);
    self:removeBuff(unit,self.HUMMER_BUFF_LIST[1].ID);
    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.HUMMER_BREAK_MESSAGE_LIST);
    if self.isGlab then
        self:releaseGlab(unit);
    end

    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setSkin("1");
    self:execAddBuff(unit,self.STUN_BUFF_LIST[1]);
end

function class:isFreeze(unit)
    for _,type in ipairs(self.FREEZE_TYPES) do
        if unit:getTeamUnitCondition():findConditionWithType(type) ~= nil then
            return true;
        end
    end
    return false;
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end

    if event.spineEvent == "glab" then self:glab(event.unit); end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit); end
    if event.spineEvent == "throw" then self:throw(event.unit); end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit); end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit); end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit); end
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

    ---ハンマー抜刀でハンマー状態に入る
    if event.index == 3 then
        self:getRage(event.unit);
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
    ---奥義11の後のハンマー抜刀（行動パターンは進めない）
    if self.hummerAttackIndex ~= nil then
        attackIndex = self.hummerAttackIndex;
        self.hummerAttackIndex = nil;
    else
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
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

    if event.index == 1 then
        ---奥義5（掴みは attack5 のアニメ。掴み判定がアニメの途中にあり skill1_throw へ繋げられる）
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5");
    elseif event.index == 2 then
        ---奥義6
        self:showMessage(self.SKILL2_MESSAGE_LIST);
    elseif event.index == 3 then
        ---奥義10
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
        self:showMessage(self.SKILL3_MESSAGE_LIST);
    elseif event.index == 4 then
        ---奥義11（打ち終わったらハンマー抜刀）
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
        self:showMessage(self.SKILL4_MESSAGE_LIST);
        if self.USE_HUMMER and not self.isRage then
            self.hummerAttackIndex = 3;
        end
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
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
    ---掴みが当たった時点で攻撃力の一番高いユニットを掴む
    if self.tryGlab and self.glabTargetIndex == nil then
        self.glabTargetIndex = self:checkGlabTarget();
        self:checkGlabSucsess(event.unit);
    end
    ---ハンマー攻撃は氷結状態のユニットを即死させる
    if event.unit:getActiveSkillAsInt() == self.ACTIVE_SKILLS.ATTACK4 and self:isFreeze(event.enemy) then
        event.enemy:setHP(0);
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
    ---ブルーゴブルの数に応じて被ダメージ軽減（ハンマーのエクストラゲージにも効く）
    if self.friendCount > 0 then
        event.value = event.value * math.max(0,1 - self.GD.summonDmgCutRate * self.friendCount);
    end

    if self.isRage then
        ---ハンマー状態：ダメージはエクストラゲージへ入れ、ボスへのダメージは1にする
        self.damage = self.damage + event.value;
        event.value = 1;
    else
        event.value = self:adjustOnePunch(event.unit,event.value);
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（レイドでは呼ばれない）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    elseif self.isRage then
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
    ---ワンパン対策の奥義11は発動から打ち終わるまでブレイク不可
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

    ---ハンマー状態はブレイクでハンマー破壊
    if self.isRage then
        self:weaponBreak(event.unit);
    end
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
            self.hpSkillFLG = false;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:releaseGlab(event.unit);
    self.subBarOnePunch:setVisible(false);
    if self.USE_HUMMER then
        self.subBar:setVisible(false);
    end
    self:friendDead();
    megast.Battle:getInstance():waveEnd(true);
    return 1;
end

---ボスが倒れたらブルーゴブルも倒す
function class:friendDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil and myTeamUnit:getIndex() ~= self.gameUnit:getIndex() then
            myTeamUnit:setHP(0);
            myTeam:deadUnit(myTeamUnit:getIndex());
        end
    end
end

function class:receive4(args)
    return 1;
end


--===================================================================================================================
-- 掴み＆掴み投げ（奥義5）
--===================================================================================================================
function class:glab(unit)
    self.tryGlab = true;
end

---攻撃力の一番高いユニット
function class:checkGlabTarget()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local index = nil;
    local attack = -1;
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getHP() > 0 and u:getCalcAttack() > attack then
            attack = u:getCalcAttack();
            index = i;
        end
    end
    return index;
end

---掴みの判定。当たっていなくても攻撃力の一番高いユニットを掴む
function class:checkGlabSucsess(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex == nil then
        self.glabTargetIndex = self:checkGlabTarget();
    end
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,10,100 + self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,10,200);
    end
end

---掴んだ時点のバトル経過時間で固定ダメージと奥義ゲージDOWN量を決める
function class:glabExecute(unit,index)
    self.glabTargetIndex = index;
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);

    local time = math.floor(BattleControl:get():getTime());
    self.throwFixDmg = math.floor(time * self.GD.throwFixDmgRate);
    self.throwDownBP = math.min(math.floor(time * self.GD.throwDownBPRate),self.GD.throwDownBPMax);
    self:showFormatMessage(self.GLAB_MESSAGE_LIST[1],self.throwFixDmg);
    self:showMessage(self.GLAB_MESSAGE_LIST,2);
    self:showMessage(self.GLAB_MESSAGE_LIST,3);

    local glabUnit = self:getUnitByIndex(index);
    if glabUnit ~= nil then
        self:execAddBuff(glabUnit,self.GLAB_BUFF_LIST[1]);
    end
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

---掴み投げ：固定ダメージと奥義ゲージDOWN
function class:throwEnd(unit)
    if not self.isGlab then
        return;
    end
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end
    glabUnit._autoZorder = true;

    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);
    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(self.ACTIVE_SKILLS.SKILL9);

    local bp = glabUnit:getBurstPoint() - self.throwDownBP;
    if bp < 0 then
        bp = 0;
    end
    glabUnit:setBurstPoint(bp);
    local artsHpBefore = glabUnit:getHP()
    glabUnit:setHP(glabUnit:getHP() - self.throwFixDmg);
    -- 【MEGA_D-9756】メッセージログで、この技の行に減った HP を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
    if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
        megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, glabUnit, artsHpBefore - glabUnit:getHP())
    end
end

function class:glabFaild(unit)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    unit:setAnimation(0,"skill1_miss",false);
end

---掴みを中断してユニットを解放する（固定ダメージ・奥義ゲージDOWNはしない）
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
    glabUnit:getSkeleton():setPosition(0,0);
    glabUnit._autoZorder = true;
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end
    self:execAddBuff(glabUnit,self.GLAB_BUFF_LIST[1]);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end


--===================================================================================================================
-- 投射物・毒瓶
--===================================================================================================================
-- 行動パターンとは別枠で grenadeRecast 秒ごとに
-- スキル7（投射物・中身はランダム）→ スキル8（毒瓶）→ 繰り返し で投げる。
function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast then
        self.grenadeTimer = 0;
        if megast.Battle:getInstance():isHost() then
            self:takeGrenadeAnimation(self.gameUnit,self.grenadeTurn);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,10,300 + self.grenadeTurn);
            self.grenadeTurn = self.grenadeTurn == 1 and 2 or 1;
        end
    end
end

---goblin_attack2 は lunchOther、goblin_attack は lunchPoisonGrenade を飛ばす
function class:takeGrenadeAnimation(unit,turn)
    if turn == 1 then
        unit:setAnimation(1,"goblin_attack2",false);
    else
        unit:setAnimation(1,"goblin_attack",false);
    end
end

---スキル7 投射物（中身はランダム）
function class:lunchOther(unit)
    local rand = LuaUtilities.rand(0,100);
    local arg = self.ORBIT_ARGS.IRON;
    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    end
    self:lunch(unit,arg);
end

---スキル8 毒瓶
function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POISON);
end

function class:lunch(unit,arg)
    if unit:getHP() <= 0 then
        return;
    end
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
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

    LuaUtilities.runJumpTo(bullet,3,targetx,targety,400,1);
end

function class:getUnitByIndex(index)
    if index == nil then
        return nil;
    end
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end


--===================================================================================================================
-- ブルーゴブル召喚
--===================================================================================================================
function class:findFriend()
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil and myTeamUnit:getEnemyID() == self.SUMMON_ID then
            self.friendCount = self.friendCount + 1;
        end
    end
end

---summonRecast 秒ごとに召喚する
function class:summonCheck(deltaTime)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    self.summonTimer = self.summonTimer + deltaTime;
    if self.summonTimer < self.GD.summonRecast then
        return;
    end
    self.summonTimer = 0;
    local num = self:getSummonNum();
    if num <= 0 then
        return;
    end
    self:MultipleSummon(self.gameUnit,self.SUMMON_ID,num);
    self:showMessage(self.SUMMON_MESSAGE_LIST);
    if self.summonCount == 0 then
        self:showMessage(self.FIRST_SUMMON_MESSAGE_LIST);
    end
    self.summonCount = self.summonCount + 1;
end

---1体または2体（初回は固定数）。最大数を超える分は召喚しない
function class:getSummonNum()
    local space = self.GD.summonMax - self.friendCount;
    if space <= 0 then
        return 0;
    end
    local num = 1;
    if self.USE_FIRST_SUMMON and self.summonCount == 0 then
        num = self.GD.summonFirstNum;
    elseif LuaUtilities.rand(0,100) < self.GD.summonTwoRate then
        num = 2;
    end
    return math.min(num,space);
end

function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break;
            end
        end
    end
end

function class:MultipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID);
    end
end


--===================================================================================================================
-- マルチ同期
--===================================================================================================================
---------------------------------------------------------------------------------
-- receive10（掴み成功／掴み失敗／投射アニメの同期）
---------------------------------------------------------------------------------
function class:receive10(args)
    local kind = math.floor(args.arg / 100);
    local value = args.arg % 100;
    if kind == 1 then
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
        return
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
end

function class:removeBuff(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
end

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

class.STATE_ATTACK = {};
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


class:publish();

return class;
