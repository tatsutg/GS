local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="試練の回廊_35層_闇玉精プルートゥ", version=2.6, id=2000696});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK4 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    },
    LAMP = {
        { SKILL1 = 50 },
        { SKILL4 = 50 },
        { SKILL2 = 50 },
        { SKILL4 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

class.cutInSkill = {
    --[3] = 1
}

---クリスタル関係
class.CRYSTAL_NUM = 3;
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5,
    start2 = 6
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20006961,
            BUFF_ID = 53,  --毒耐性
            VALUE = self.GD.hpBuffValue_53,
            DURATION = 999999,
            ICON = 59
        },
        [2] = {
            ID = 20006962,
            BUFF_ID = 102,  --毒回避率
            VALUE = self.GD.hpBuffValue_53,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 20006963,
            BUFF_ID = 22,  --クリティカル率
            VALUE = self.GD.hpBuffValue_22,
            DURATION = 999999,
            ICON = 11
        }
    }
    self.LAMP_BUFF_BOX_LIST = {
        [1] = {
            ID = 200069610,
            BUFF_ID = 15,   --防御力UP
            VALUE = self.GD.lamp1BuffValue_15,
            DURATION = 999999,
            ICON = 5
        },
        [2] = {
            ID = 200069611,
            BUFF_ID = 17,   --与ダメUP
            VALUE = self.GD.lamp1BuffValue_17,
            DURATION = 999999,
            ICON = 26
        },
        [3] = {
            ID = 200069612,
            BUFF_ID = 23,   --クリティカル耐性
            VALUE = self.GD.lamp2BuffValue_23,
            DURATION = 999999,
            ICON = 188
        },
        [4] = {
            ID = 200069613,
            BUFF_ID = 7,  --自然回復
            VALUE = self.GD.lamp3BuffValue_7,
            DURATION = 999999,
            ICON = 35,
            SCRIPT = {
                SCRIPT_ID = 238
            }
        },
        [5] = {
            ID = 200069614,
            BUFF_ID = 17,   --クリティカルダメージUP
            VALUE = self.GD.lamp3BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 200069650,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.GD.targetBuffVal_23_1,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 200069650,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 99999,
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
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "累計ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットした者へのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間経過でオーブが点灯：毒で遅延", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "毒耐性アップ・行動速度アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "消灯数に応じてオーブが点灯：1つ点灯", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE3 or "消灯数に応じてオーブが点灯：全て点灯", COLOR = Color.yellow})
    }
    self.LIGHTON1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON1_MESSAGE1 or "ダメージアップ・防御力大幅アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON1_MESSAGE2 or "ブレイク・一定時間病気状態維持で消灯", COLOR = Color.yellow})
    }
    self.LIGHTON2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON2_MESSAGE1 or "クリティカル耐性・奥義ゲージ上昇量・ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON2_MESSAGE2 or "ブレイク・一定時間病気状態維持で消灯", COLOR = Color.yellow})
    }
    self.LIGHTON3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON3_MESSAGE1 or "被ダメージ大幅軽減・自然回復・ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON3_MESSAGE2 or "不死状態", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON3_MESSAGE3 or "ブレイク・一定時間病気状態維持で消灯", COLOR = Color.yellow})
    }
    self.LIGHTOFF1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF1_MESSAGE1 or "防御力・ダメージアップ：解除", COLOR = Color.red})
    }
    self.LIGHTOFF2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF2_MESSAGE1 or "クリティカル耐性・奥義ゲージ上昇量・ダメージアップ：解除", COLOR = Color.red})
    }
    self.LIGHTOFF3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF3_MESSAGE1 or "被ダメージ大幅軽減・自然回復・ダメージアップ：解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF3_MESSAGE2 or "不死状態解除！", COLOR = Color.red})
    }
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
        }
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
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP60_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2]);
        self.gameUnit:setAttackDelay(self.GD.hp60AttackDelay);
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP30_MESSAGE_LIST,1);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3]);
        ---玉点灯
        --玉の点灯が0ならタイマーを出す
        if self.crystalCounter == 0 then
            self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerB, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
            self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB ,0);
            self.timeSpeedB = 0;
        end

        --一度も消灯ギミックを踏んでいない場合
        local num = 0;
        if not self.lampDownFlg then
            num = 3;
            self:showMessage(self.HP30_MESSAGE_LIST,3);
        else
            self:showMessage(self.HP30_MESSAGE_LIST,2);
        end

        for i = 0,num do
            self.crystalCounter = self.crystalCounter + 1;
            if self.crystalCounter > self.CRYSTAL_NUM then
                self.crystalCounter = self.CRYSTAL_NUM;
            else
                self:lightUp(self.gameUnit,self.crystalCounter);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        lamp2AddSP = 35,
        startAddSP = 0,
        attackDelay = 8,
        hp60AttackDelay = 5,
        hitStop = 100,

        tgTimer = 20,
        tgLimit = 99,
        tgIconNum1 = 3,
        tgIconNum2 = 0,
        tgPosX = -80,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.3,
        tgSlowBuffType1 = 90,

        tgTimerB = 120,
        tgLimitB = 99,
        tgIconNum1B = 4,
        tgIconNum2B = 0,
        tgPosXB = 80,
        tgPosYB = 0,
        tgScaleB = 1,
        tgSlowBuffTypeB = 94,

        crystalLeftX = -300,
        crystalLeftY = 500,
        crystalCenterX = 0,
        crystalCenterY = 530,
        crystalRightX = 300,
        crystalRightY = 500,
        crystalZOrder = 1,

        lampDmgValRate = 0.05,
        lamp1BuffValue_15 = 5000,
        lamp1BuffValue_17 = 40,
        lamp2BuffValue_23 = -200,
        lamp3BuffValue_7 = 3,
        lamp3BuffValue_17 = 100,

        hpBuffValue_53 = 30,
        hpBuffValue_22 = 50,
        targetBuffVal_23_1 = 20,
        targetBuffVal_23_2 = 20
    })
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

    ---経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.timeIndexB = nil;
    self.timeSpeedB = nil;

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    self.targetUnitList = {};
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    ---クリスタル関係
    self.CRYSTAL_POSITIONS = {
        {x = self.GD.crystalLeftX,y = self.GD.crystalLeftY},
        {x = self.GD.crystalRightX,y = self.GD.crystalRightY},
        {x = self.GD.crystalCenterX,y = self.GD.crystalCenterY}
    };
    self.crystals = {};
    self.crystalBuffs = {};
    self.crystalDBuffs = {};
    self.crystalCounter = 0;
    self.crystalExcutionFlg = false;
    self:initCrystals(event.unit);
    self:setUpCrystalBuffs(event);

    ---ボスギミック
    self.lampDmgVal = 1;
    self.lampDownFlg = false;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    self:extraTimerOperation(event.unit);
    if self.crystalCounter > 0 then
        if self.timeIndexB ~= nil then
            self:extraTimerOperationB(event.unit);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndex then
        ---玉点灯
        --玉の点灯が0ならタイマーを出す
        if self.crystalCounter == 0 then
            self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerB, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
            self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB ,0);
            self.timeSpeedB = 0;
        end
        self.crystalCounter = self.crystalCounter + 1;
        if self.crystalCounter > self.CRYSTAL_NUM then
            self.crystalCounter = self.CRYSTAL_NUM;
        else
            self:lightUp(event.unit,self.crystalCounter);
        end
    elseif event.index == self.timeIndexB then
        self.lampDownFlg = true;
        ---玉消し
        if self.crystalCounter > 0 then
            self:lightDown(event.unit,self.crystalCounter);
            self.crystalCounter = self.crystalCounter - 1;
        end
        --玉の点灯が0ならタイマーを消す
        if self.crystalCounter == 0 then
            if self.timeIndexB ~= nil then
                megast.Battle:getInstance():removeExtraTimer(self.timeIndexB ,1 ,1 ,true);
                self.timeIndexB = nil;
                self.timeSpeedB = nil;
            end
        end
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    local flg = "";
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    -- デバフ状態かどうか
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(self.GD.tgSlowBuffType1);
    if cond1 ~= nil then
        flg = "changeOn";
    elseif cond1 == nil and nowSpeed ~= 1 then
        flg = "changeOff";
    end

    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlg then
        flg = "stop";
    elseif not unit:isBreak() and self.breakFlg then
        self.breakFlg = false;
        flg = "changeOff";
    end

    -- 無敵中は止める
    if unit:getInvincibleTime() > 0 then
        flg = "stop";
    end

    --３つ点灯してた場合は停止
    if self.crystalCounter == 3  then
        flg = "stop";
    end

    if flg == "stop" then
        self:extraTimer("stop" ,self.timeIndex);
    elseif flg == "changeOn" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,self.GD.deBuffTimeSpeed);
    elseif flg == "changeOff" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end
end

function class:extraTimerOperationB(unit)
    local flg = "";
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    -- デバフ状態かどうか
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(self.GD.tgSlowBuffTypeB);
    if cond1 ~= nil and nowSpeed == 0 then
        flg = "changeOff";
    elseif cond1 == nil and nowSpeed ~= 0 then
        flg = "stop";
    end

    if flg == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB ,0);
    elseif flg == "changeOff" then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB, 1);
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
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end

    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit); end
    if event.spineEvent == "skill2Start" then self:skill2Start(); end
    if event.spineEvent == "skill2Compleat" then self:skill2Compleat(); end
    return 1;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    -- self.crystalCounter = 0;
    self:restertCrystals();
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
    end
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

    --if event.index == 1 then
    --    event.unit:setNextAnimationName("attack1");
    --    event.unit:setNextAnimationEffectName("1-attack1");
    --end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
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

    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 4 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
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
    ---玉の点灯数によりダメージ補正
    event.value = event.value + self.lampDmgVal;
    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value; end
    ---ユニットのダメージをテーブルに格納
    local enemyUnit = self:getAncestorUnit(event.enemy);
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value});
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value;
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex());---ゲストにターゲットを送る
        event.unit:setHateTarget(target);
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.TARGET_BUFF_LIST1.VALUE = self.GD.targetBuffVal_23_1 + self.GD.targetBuffVal_23_2 * self.crystalCounter;
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
                end
            end
        end
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

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            target = myTeamUnit;
            break;
        end
    end
    local val = 0;
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0;
        elseif v.dps >= val then
            val = v.dps;
            target = v.unit;
        end
    end
    return target;
end

function class:receive6(args)
    ---ヘイトは全部手動で設定する
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = myTeam:getTeamUnit(args.arg);
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    return 1;
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
    ---玉消し
    if self.crystalCounter > 0 then
        self.lampDownFlg = true;
        self:lightDown(event.unit,self.crystalCounter);
        self.crystalCounter = self.crystalCounter - 1;
    end
    --玉の点灯が0ならタイマーを消す
    if self.crystalCounter == 0 then
        if self.timeIndexB ~= nil then
            --ロックアニメーションが残るので一度解除する
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB, 1);
            megast.Battle:getInstance():removeExtraTimer(self.timeIndexB ,1 ,1 ,true);
            self.timeIndexB = nil;
            self.timeSpeedB = nil;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    --玉が３つ点灯している場合は死なない
    if self.crystalCounter >= 3 then
        event.unit:setHP(1);
        return 0;
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

---トリガー時状態異常除去---
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



--====================================================================================================================================
--クリスタル関係

function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(self.GD.crystalZOrder);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:setUpCrystalBuffs(event)
    self.crystalBuffs[1] = {action = function(luaInstance,unit)
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[1]);
        luaInstance.LAMP_BUFF_BOX_LIST[2].VALUE = luaInstance.GD.lamp1BuffValue_17 * 1;
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:showMessage(luaInstance.LIGHTON1_MESSAGE_LIST);
    end
    }
    self.crystalBuffs[2] = {action = function(luaInstance,unit)
        luaInstance.LAMP_BUFF_BOX_LIST[2].VALUE = luaInstance.GD.lamp1BuffValue_17 * 2;
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[3]);
        luaInstance:changeAddSP(luaInstance.GD.lamp2AddSP);
        luaInstance:showMessage(luaInstance.LIGHTON2_MESSAGE_LIST);
    end
    }
    self.crystalBuffs[3] = {action = function(luaInstance,unit)
        luaInstance.LAMP_BUFF_BOX_LIST[2].VALUE = luaInstance.GD.lamp1BuffValue_17 * 3;
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[4]);
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[5]);
        luaInstance:showMessage(luaInstance.LIGHTON3_MESSAGE_LIST);
        luaInstance:changeDmgVal(luaInstance.GD.lampDmgValRate);
        luaInstance:initSkillWeight({LAMP = 100});
    end
    }
    self.crystalDBuffs[1] = {action = function(luaInstance,unit)
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[1].ID);
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2].ID);
        luaInstance:showMessage(luaInstance.LIGHTOFF1_MESSAGE_LIST);
    end
    }
    self.crystalDBuffs[2] = {action = function(luaInstance,unit)
        luaInstance.LAMP_BUFF_BOX_LIST[2].VALUE = luaInstance.GD.lamp1BuffValue_17 * 1;
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[3].ID);
        luaInstance:changeAddSP(luaInstance.GD.addSP);
        luaInstance:showMessage(luaInstance.LIGHTOFF2_MESSAGE_LIST);
    end
    }
    self.crystalDBuffs[3] = {action = function(luaInstance,unit)
        luaInstance.LAMP_BUFF_BOX_LIST[2].VALUE = luaInstance.GD.lamp1BuffValue_17 * 2;
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[4].ID);
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[5].ID);
        luaInstance:showMessage(luaInstance.LIGHTOFF3_MESSAGE_LIST);
        luaInstance:changeDmgVal(1);
        luaInstance:initSkillWeight({DEFAULT = 100});
    end
    }
end

function class:changeAddSP(num)
    self.spValue = num;
end

function class:changeDmgVal(num)
    self.lampDmgVal = num;
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        --self.crystalBuffs[num] = nil;
    end

    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end

function class:lightDown(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalDBuffs[num] ~= nil then
        self.crystalDBuffs[num].action(self,unit);
        --self.crystalDBuffs[num] = nil;
    end

    if self.crystals[num].state == self.CRYSTAL_STATES.active then
        self.crystals[num].switchState(self,self.crystals[num],self.CRYSTAL_STATES.deactive);
    end
end



class:publish();

return class;