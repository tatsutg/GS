local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡10層_HARD_ジオ＝ザグナス", version=2.6, id=2061195});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK5 = 50 }
    },
    HUMMER = {
        { ATTACK4 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    },
    HP50 = {
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL10 = 3,  --ハンマー抜刀
    ATTACK4 = 4,
    ATTACK5 = 5,  --掴み
    ATTACK6 = 6,  --投擲物
    ATTACK7 = 7,  --毒瓶
    ATTACK8 = 8,  --掴み投げ
    SKILL1 = 9,
    SKILL2 = 10,
    SKILL3 = 11,
    ATTACK10 = 12,  --毒瓶
    ATTACK11 = 13,  --毒瓶
    ATTACK12 = 14  --毒瓶
}

class.cutInSkill = {
    --[3] = 1
}

---
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

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
    POISON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 7
    },
    POISON1 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 12
    },
    POISON2 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 13
    },
    POISON3 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 14
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}

--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;

class.GRENADE_RECAST = 10;


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 20611951,
            BUFF_ID = 112,  --状態異常耐性
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 77,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 20611952,
            BUFF_ID = 113, --状態異常回避率
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        }
    }
    self.DE_BUFF_LIST = {
            ID = 20611953,
            BUFF_ID = 17,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,  --26
            COUNT = 0,
            MAX = 99
    }
    self.TIME_BUFF_LIST = {
        [1] = {
            ID = 20611954,
            BUFF_ID = 17, --与ダメUP
            VALUE = self.GD.tgBuffVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 20611955,
            BUFF_ID = 22, --クリティカル率
            VALUE = self.GD.tgBuffVal_22,
            DURATION = 999999,
            ICON = 11,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = 20611956,
            BUFF_ID = 112, --状態異常耐性
            VALUE = self.GD.tgBuffVal_112,
            DURATION = 999999,
            ICON = 77,
            COUNT = 0,
            MAX = 99
        },
        [4] = {
            ID = 20611957,
            BUFF_ID = 113, --状態異常回避率
            VALUE = self.GD.tgBuffVal_112,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        },
        [5] = {
            ID = 20611958,
            BUFF_ID = 142, --スーパークリティカル率
            VALUE = self.GD.tgBuffVal_142,
            DURATION = 999999,
            ICON = 229,
            COUNT = 0,
            MAX = 99
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 2061199,
        BUFF_ID = 89,  --気絶効果
        VALUE = 100,
        DURATION = self.GD.buffTime_89,
        ICON = 79
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 206119550,
        BUFF_ID = 21,  --被ダメージUP
        VALUE = self.GD.targetBuffVal_21,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 206119550,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットへの与ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過でダメージアップ：暗闇で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "状態異常の数が多いほど、プレイヤーユニットの被ダメージアップ", COLOR = Color.yellow})
    }
    self.GLAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE1 or "掴み投げ：庇う無効", COLOR = Color.yellow})
    }
    self.HUMMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE1 or "ハンマー状態：魔法ダメージで解除", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE2 or "ハンマー状態：物理ダメージで解除", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE3 or "ハンマー状態：クリティカルでないダメージで解除", COLOR = Color.white})
    }
    self.HUMMER_LOST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_LOST_MESSAGE1 or "ハンマー状態解除成功！", COLOR = Color.red})
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE2 or "状態異常耐性ダウン", COLOR = Color.red, isPlayer = true})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "状態異常耐性ダウン", COLOR = Color.red, isPlayer = true})
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "状態異常耐性ダウン", COLOR = Color.red, isPlayer = true})
    }
    self.ELEMENT_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE1 or "属性ユニットからの被ダメージを軽減", COLOR = Color.red})
    }
    self.elementName = {
        [0] = self.TEXT.ELEMENT0 or "無",
        [1] = self.TEXT.ELEMENT1 or "炎",
        [2] = self.TEXT.ELEMENT2 or "水",
        [3] = self.TEXT.ELEMENT3 or "樹",
        [4] = self.TEXT.ELEMENT4 or "光",
        [5] = self.TEXT.ELEMENT5 or "闇"
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
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp75(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self.invincibleFlg = true;
        self:setMessage(self.HP75_MESSAGE_LIST);
        self.spValue = self.GD.hpAddSP1;
        self.hpFlg = true;
        self:resetTarget();
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self.invincibleFlg = true;
        self:setMessage(self.HP50_MESSAGE_LIST);
        self.gameUnit:setAttackDelay(self.GD.hpAttackDelay);
        self.hpFlg = true;
        self.hp50Flg = true;
        self:initSkillWeight({HP50 = 100});
        self:resetTarget();
    end
end

function class:hp25(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self.invincibleFlg = true;
        self:setMessage(self.HP25_MESSAGE_LIST);
        self.spValue = self.GD.hpAddSP2;
        self.hpFlg = true;
        self:resetTarget();
    end
end

function class:setMessage(messages)
    self:showMessage(messages,1);
    self:setTargetElement();
    self:showFormatMessages(self.ELEMENT_MESSAGE_LIST,self.elementName[self.targetElement]);
    self:showMessage(messages,2);
end

function class:showFormatMessages(messages,str)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(str..v.MESSAGE,v.DURATION,v.COLOR);
    end
end

function class:setTargetElement()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == self.targetUnitIndex then
                self.targetElement = myTeamUnit:getElementType();
            end
        end
    end
end

function class:resetTarget()
    self.targetUnitList = {};
    self.targetUnitIndex = nil;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,

        hpAddSP1 = 30,
        hpAttackDelay = 5,
        hpAddSP2 = 35,

        tgTimer = 15,
        tgTimer2 = 3,
        tgLimit = 99,
        tgIconNum1 = 26,
        tgIconNum2 = 0,
        tgPosX = -40,
        tgPosX2 = 40,
        tgPosY = 0,
        tgScale = 1,
        tgDeBuffTimeSpeed = 0.5,

        grenadeRecast = 5,
        hummerOnDmgVal = 0.01,
        subHpRate1 = 0.2,
        subHpRate2 = 0.3,
        subHpRate3 = 0.4,

        buffVal_112 = -30,
        buffTime_89 = 3,
        tgBuffVal_17 = 20,
        tgBuffVal_22 = 5,
        tgBuffVal_112 = -15,
        tgBuffVal_142 = 2,
        targetBuffVal_21 = 30,
        deBuff_BuffVal_17 = 40
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.timeIndex2 = nil;
    self.timeSpeed2 = nil;

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    self.targetUnitList = {};
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetUnitIndex = nil;

    ---サブHPギミック
    self.subBarFlg = false;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = 0;---サブバーのHP
    self.damage = 0;---サブバー表示時のダメージ

    ---ボスギミック
    self.attackFlg = false;
    self.hpFlg = false;
    self.hpSkillFlg = false;
    self.hp50Flg = false;
    self.invincibleFlg = false;
    self.throwSetter = 0;
    self.deBuffCount = 0;
    self.takeHummerCount = 0;
    self.targetElement = nil;

    ---つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    ---投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    ---武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();
    ---足関係
    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.DE_BUFF_LIST);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    --HPトリガー後のハンマー抜刀
    if event.unit:getUnitState() ~= kUnitState_skill and self.hpSkillFlg then
        self.hpSkillFlg = false;
        self.hpSkill = 10;
        self.saveBP = self.gameUnit:getBurstPoint();
        self.gameUnit:addSP(100);
    end
    --デバフ数チェックギミック
    self:checkUnitDeBuff(event.unit);
    --サブバーギミック
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end
    -- 経過時間ギミック
    self:extraTimerOperation(event.unit);
    --掴み時に奥義発動した場合の対策
    if event.unit:getUnitState() == kUnitState_skill and self.isGlab and self.glabTargetIndex ~= nil then
        self:throwEnd(event.unit);
    end
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    --投擲物関係
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

function class:checkUnitDeBuff(unit)
    self.deBuffCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local conditionSize = myTeamUnit:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize == 0 then return 0; end
            for l = 0,(conditionSize - 1) do
                local cond = myTeamUnit:getTeamUnitCondition():getAllConditionsAt(l);
                if cond ~= nil then
                    local flg = false;
                    if self:conditionTypeCheck(cond) then
                        flg = true;
                    end

                    if flg then
                        self.deBuffCount = self.deBuffCount + 1;
                    end
                end
            end
        end
    end

    if self.deBuffCount >= 4 then self.deBuffCount = 4; end
    if self.deBuffCount > 0 then
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.DE_BUFF_LIST.ID);
        if buff ~= nil then
            buff:setValue(self.deBuffCount * self.GD.deBuff_BuffVal_17);
            buff:setNumber(self.deBuffCount);
            buff:setThumbnailID(26);
        end
    else
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.DE_BUFF_LIST.ID);
        if buff ~= nil then
            buff:setValue(self.deBuffCount);
            buff:setNumber(self.deBuffCount);
            buff:setThumbnailID(0);
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

-- 毒、暗闇(ナイトメア)、病気、呪いのときTrueを返す
function class:conditionTypeCheck(condition)
    local badStatusList = { 90,93,94,95,131 };
    for k,v in pairs(badStatusList) do
        if condition:getConditionTypeAsInt() == v then
            return true;
        end
    end
    return false;
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage) / self.SUB_HP);
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self:weaponBreak(unit);
    end
end

function class:extraTimerOperation(unit)
    local flg = "";
    local condFlg = false;
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(93);  --暗闇
    if cond1 ~= nil then condFlg = true; end
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);

    -- 暗闇状態かどうか
    if condFlg and nowSpeed == 1 then
        flg = "changeOn";
    elseif not condFlg and nowSpeed ~= 1 then
        flg = "changeOff";
    end

    -- 無敵中は止める
    if unit:getInvincibleTime() > 0 and self.invincibleFlg then
        flg = "stop";
    elseif unit:getInvincibleTime() == 0 and self.invincibleFlg then
        self.invincibleFlg = false;
        flg = "changeOff";
    end

    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlg then
        flg = "stop";
    elseif not unit:isBreak() and self.breakFlg then
        self.breakFlg = false;
        flg = "changeOff";
    end

    if flg == "stop" then
        self:extraTimer("stop" ,self.timeIndex);
    elseif flg == "changeOn" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,self.GD.tgDeBuffTimeSpeed);
    elseif flg == "changeOff" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == 0 then
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[1]);
    elseif event.index == 1 then
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[2]);
    elseif event.index == 2 then
        self:setUnitDeBuff();
    elseif event.index == 3 then
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[5]);
    end
    return event.count;
end

function class:setUnitDeBuff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.TIME_BUFF_LIST[3]);
            self:execAddBuff(myTeamUnit,self.TIME_BUFF_LIST[4]);
        end
    end
end

--extraTimer操作系
function class:extraTimer(str,timeIndex,timeSpeed,changeSpeed,buffIcon,skillIndex)
    if str == "start" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed);
    elseif str == "change" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed * changeSpeed);
    elseif str == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,0);
    elseif str == "reset" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerPercentage(timeIndex ,0);
    elseif str == "delete" then
        --removeExtraTimer(int index,float fadeTime,float delayTime,bool isAnimation);
        megast.Battle:getInstance():removeExtraTimer(timeIndex ,1 ,1 ,true);
    elseif str == "iconChange" then
        --setExtraTimerBuffIcon(int index,int iconNumber,int iconNumber2);
        megast.Battle:getInstance():setExtraTimerBuffIcon(timeIndex ,buffIcon ,0);
    elseif str == "setSkill" then
        --setExtraTimerBattleSkill(int index,int skillIndex);
        megast.Battle:getInstance():setExtraTimerBattleSkill(timeIndex ,skillIndex);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
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

    if event.index == 5 then
        self.attackFlg = true;
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
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

    if self.hpFlg then
        self.hpFlg = false;
        self.hpSkillFlg = true;
        self:takeSkillDeBuff();
    end

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 2 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 10 then
        event.unit:setNextAnimationName("attack3");
        event.unit:setNextAnimationEffectName("1-attack3");
        self:getRage(event.unit);
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
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

function class:takeSkillDeBuff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_LIST[1]);
            self:execAddBuff(myTeamUnit,self.BUFF_LIST[2]);
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = self:checkTarget(event.unit)
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value
end

function class:checkTarget(unit)
    local index = nil;
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if localUnit:getIndex() == self.targetUnitIndex then
                index = localUnit:getIndex();
            end
        end
    end
    return index;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---ハンマーギミックのダメージ補正
    if self.subBarFlg then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if self.takeHummerCount == 1 then
            --魔法ダメージ
            if attribute == 2 then
                self.damage = self.damage + event.value;
            end
        elseif self.takeHummerCount == 2 then
            --物理ダメージ
            if attribute == 1 then
                self.damage = self.damage + event.value;
            end
        elseif self.takeHummerCount == 3 then
            --通常ダメージ（クリティカル、スーパークリティカルでないダメージ）
            local critical = event.unit:getTeamUnitCondition():getDamageAffectInfo().critical;
            if not critical then
                self.damage = self.damage + event.value;
            end
        end
        event.value = 1;
    end
    ---ターゲットの属性ダメージを補正
    if self.targetElement ~= nil then
        if enemyUnit:getElementType() == self.targetElement then
            event.value = event.value * self.GD.hummerOnDmgVal;
        end
    end

    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value end
    ---ユニットのダメージをテーブルに格納
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit();
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetUnitIndex = target:getIndex();
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end
    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0
        elseif v.dps >= val then
            val = v.dps
            target = v.unit
        end
    end
    return target
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
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
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

    ---ハンマーギミック
    if self.subBarFlg then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self:weaponBreak(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.state == self.WEAPON_STATES.HUMMER then
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
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
                    self:execTrigger(index)
                end
            else
                ---ブレイクスルー
                self:execTrigger(index)
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    self.TRIGGERS[index].action(action)
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
    end
    return 1
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

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
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
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
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


--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true;
end

function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        self:showMessage(self.GLAB_MESSAGE_LIST);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
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
    hit:setActiveSkill(8);

    if self.attackFlg then
        self.attackFlg = false;
        self:addSP(self.gameUnit);
    end
end

function class:glabFaild(unit)
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end

    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end

--===============================================================================================================================================
--投擲物関連のメソッド/
------------------
function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast and self:isHost() then
        self.grenadeTimer = 0;
        self.throwSetter = self.throwSetter + 1;
        if not self.hp50Flg then
            if self.throwSetter > 2 then self.throwSetter = 1; end
        else
            if self.throwSetter > 6 then self.throwSetter = 1; end
        end

        if self.throwSetter == 1 then
            self:takeOtherAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
        else
            self:takePoizonGrenadeAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        end
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    if not self.hp50Flg then
        local rand = LuaUtilities.rand(0,3);
        if rand == 0 then
            self:lunch(unit,self.ORBIT_ARGS.POISON);
        elseif rand == 1 then
            self:lunch(unit,self.ORBIT_ARGS.POISON1);
        elseif rand == 2 then
            self:lunch(unit,self.ORBIT_ARGS.POISON2);
        elseif rand == 3 then
            self:lunch(unit,self.ORBIT_ARGS.POISON3);
        end
    else
        if self.throwSetter == 2 then
            self:lunch(unit,self.ORBIT_ARGS.POISON);
        elseif self.throwSetter == 3 then
            self:lunch(unit,self.ORBIT_ARGS.POISON1);
        elseif self.throwSetter == 4 then
            self:lunch(unit,self.ORBIT_ARGS.POISON2);
        elseif self.throwSetter == 5 then
            self:lunch(unit,self.ORBIT_ARGS.POISON3);
        end
    end
end

function class:lunchOther(unit)
    --何を投げるかランダムで決定
    local rand = LuaUtilities.rand(0,100);
    local arg = {};
    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    else
        arg = self.ORBIT_ARGS.IRON;
    end
    self:lunch(unit,arg);
end

function class:lunch(unit,arg)
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:setActiveSkill(arg.activeSkill);

    local x = unit:getPositionX()
    local y = unit:getPositionY()
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


--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    unit:setSetupAnimationName("setUpWeapon");
    self:initAttackWeight({HUMMER = 100});
    self.subBarFlg = true;
    self.damage = 0;

    --メッセージ関連
    local iconNum = 0;
    self.takeHummerCount = self.takeHummerCount + 1;
    self:showMessage(self.HUMMER_MESSAGE_LIST,self.takeHummerCount);
    if self.takeHummerCount == 1 then
        iconNum = 11;
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.subHpRate1;---サブバーのHP
    elseif self.takeHummerCount == 2 then
        iconNum = 77;
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.subHpRate2;---サブバーのHP
    elseif self.takeHummerCount == 3 then
        iconNum = 229;
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.subHpRate3;---サブバーのHP
    end

    --エクストラタイマー表示
    self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer2, 99 ,iconNum, 0, self.GD.tgPosX2, 0, 1);
    self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2);
end

function class:weaponCheck(unit,damage)
    self.WEAPON_DAMAGE = self.WEAPON_DAMAGE + damage
    if self.WEAPON_DAMAGE >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    self:initAttackWeight({DEFAULT = 100});
    self:showMessage(self.HUMMER_LOST_MESSAGE_LIST);

    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("1");

    --掴み投げ対策
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:throwEnd(unit);
    end

    --気絶効果付与
    self:execAddBuff(unit,self.STUN_BUFF_LIST);

    --エクストラタイマー
    self:extraTimer("reset" ,self.timeIndex);
    self:extraTimer("delete" ,self.timeIndex2);
    self.timeIndex2 = nil;
    self.timeSpeed2 = nil;
end

--[[
function class:subBarControll(unit,damage)
    local x = unit:getSkeleton():getBoneWorldPositionX("weapon2");
    local y = unit:getSkeleton():getBoneWorldPositionY("weapon2");
    self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    self.subBar:setPositionY(unit:getPositionY()+ y);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.WEAPON_HP - damage)/self.WEAPON_HP);
    if self.WEAPON_HP - damage <= 0 then
        self.subBar:setVisible(false);
    end
end
--]]

--===============================================================================================================================================
--マルチ同期/
----------
function class:receive7(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    self:showMessage(self.GRAB_MESSAGE_LIST)
    return 1;
end

function class:receive8(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive9(args)
    if args.arg == 0 then
        self:takePoizonGrenadeAnimation(self.gameUnit);
    else
        self:takeOtherAnimation(self.gameUnit);
    end
    return 1;
end

--===============================================================================================================================================
function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;