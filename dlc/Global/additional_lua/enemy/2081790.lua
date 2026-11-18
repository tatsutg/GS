local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="真EX極_超シモン", version=2.8, id=2081790});
class:inheritFromUnit("unitBossBase");

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 100 },
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL3 = 100 }
    },
    HP0 = {
        { SKILL5 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 6
}

class.cutInSkill = {
    [5] = 4,
    [6] = 4
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 200069301,
            BUFF_ID = 17,
            VALUE = self.GD.buffVal_17,
            DURATION = 999999,
            ICON = 26,
            MAX = 99
        },
        [2] = {
            ID = 200069302,
            BUFF_ID = 31, --回避率UP
            VALUE = self.GD.buffVal_31,
            DURATION = 999999,
            ICON = 16,
            MAX = 21
        },
        [3] = {
            ID = 200069303,
            BUFF_ID = 0, --カウント表示用/9~0まで
            VALUE = 0,
            DURATION = 999999,
            ICON = 16,
            COUNT = 0,
            MAX = 10
        }
    }
    self.HP0_BUFF_BOX = {
        [1] = {
            ID = 200069310,
            BUFF_ID = 13, --攻撃力
            VALUE = self.GD.buffVal_13,
            DURATION = 999999,
            ICON = 3
        },
        [2] = {
            ID = 200069320,
            BUFF_ID = 15, --防御力
            VALUE = self.GD.buffVal_15,
            DURATION = 999999,
            ICON = 5
        },
        [3] = {
            ID = 200069330,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        }
    }
end

--------[[メッセージ]]--------
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "貴様がE因子保持者か？", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "人族・闇属性ユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "回避率アップ：装備を使用するたびに回避率ダウン", COLOR = Color.yellow}),
    }
    self.ATTACK3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ATTACK3_MESSAGE1 or "与ダメージアップ", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "今日ここで、俺は――お前を殺す。", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "行動速度アップ", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "人を殺すべく生まれた魔弾", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "攻撃力・防御力・奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "一定時間経過でバレット・オリジン発動", COLOR = Color.yellow}),
    }
    self.TIMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE1 or "人を殺すべく生まれた魔弾", COLOR = Color.magenta}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "戒めだ、お前を甘くみていた俺への、な", COLOR = Color.magenta}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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

function class:hp50(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 5;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setAttackDelay(self.GD.hp50AttackDelay);
        self.gameUnit:setInvincibleTime(15);
        -- self:refresh(self.gameUnit);
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

function class:hp0(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 6;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.spValue = self.GD.hp0AddSP;
        self.gameUnit:setInvincibleTime(20);
        -- self:refresh(self.gameUnit);
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.GD.hp0HealRate);
        self:execAddBuff(self.gameUnit, self.HP0_BUFF_BOX[1]);
        self:execAddBuff(self.gameUnit, self.HP0_BUFF_BOX[2]);
        self:execAddBuff(self.gameUnit, self.HP0_BUFF_BOX[3]);
        self:initSkillWeight({HP0 = 100});
        self:timerStart();
        self:showMessage(self.HP0_MESSAGE_LIST);
        self.voiceFlg = true;
    end
end

function class:timerStart()
    if self.timeIndex == nil then
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 7,
        hitStop = 100,
        hp0AddSP = 40,
        hp50AttackDelay = 5,

        tgTimer = 30,
        tgLimit = 1,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,

        timerDmgVal = 0.05,
        hp0HealRate = 0.5,

        buffVal_13 = 100,
        buffVal_15 = 100,
        buffVal_17 = 10,
        buffVal_31 = 200,
        evasionMin = 0
    })
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);
    end
    event.unit:addSP(self.GD.startAddSP);
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
    self.hpSkill = 0;
    self.saveBP = 0;
    self.skill3Count = 0;
    self.hp0Phase = false;
    self.timeIndex = nil;
    self.timeSpeed = nil;
    self.timerDamageRate = 1;

    self.itemCount = 0;
    self.itemUnitList = {};
    self:initItemCheck();

    self.voiceFlg = false;
    event.unit:setCutinVoice3("VOICE_FULLARTS_CUTIN_C");
    event.unit:setCutinSE3("SE_BATTLE_AWAKENING_3_CUTIN");
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB");
    return 1;
end

function class:initItemCheck()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local battleSkill = nil;
            for j = 0,2 do
                battleSkill = myTeamUnit:getItemSkill(j);
                if battleSkill ~= nil then
                    local index = (i * 10) + j + 1;
                    local ct = battleSkill:getCoolTimer();
                    if ct > 0 then
                        -- 使っている状態
                        self.itemUnitList[index] = 2;
                    else
                        -- 装備回復
                        battleSkill:setCoolTimer(0)
                        self.itemUnitList[index] = 0;
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2]);
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
    if cond ~= nil then
        cond:setNumber(self.GD.buffVal_31 / 10);
    end
    megast.Battle:getInstance():updateConditionView();
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    ---タイマーギミック
    self:extraTimerOperation(event.unit);
    ---プレイヤーPTの装備使用ギミック
    self:useItemCheck();
    event.unit:setReduceHitStop(self.GD.hitStop,1);
    self.equipUseDetected = false;
    ---超奥義演出
    if not self.voiceFlg then
        event.unit:setCutinVoice3("VOICE_FULLARTS_CUTIN_C");
        event.unit:setCutinSE3("SE_BATTLE_AWAKENING_3_CUTIN");
    else
        event.unit:setCutinVoice3("VOICE_FULLARTS_CUTIN_FB");
        event.unit:setCutinSE3("SE_BATTLE_PHANTOMBULLET_CUTIN");
    end
    return 1;
end

--プレイヤーPTの装備使用ギミック
function class:useItemCheck()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local battleSkill = nil;
            for j = 0,2 do
                battleSkill = myTeamUnit:getItemSkill(j);
                if battleSkill ~= nil then
                    local index = (i * 10) + j + 1;
                    local ct = battleSkill:getCoolTimer()
                    if ct ~= 0 and self.itemUnitList[index] == 1 then
                        -- 使っている状態
                        self.itemCount = self.itemCount + 1;
                        self:updateEvasionBuff(self.itemCount);
                        self.itemUnitList[index] = 2;
                    elseif ct <= 0 and self.itemUnitList[index] == 2 then
                        -- 装備回復
                        self.itemUnitList[index] = 0
                        battleSkill:setCoolTimer(0);
                        --summoner.Utility.messageByEnemy("回復 "..index);
                    elseif ct ~= 0 and self.itemUnitList[index] == 0 then
                        -- 装備使用
                        self.itemUnitList[index] = 1;
                        --summoner.Utility.messageByEnemy("使用 "..index);
                    end
                end
            end
        end
    end
end

--===================================================================================================================
-- 回避率ギミック
--===================================================================================================================
function class:updateEvasionBuff(itemCount)
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
    if cond ~= nil then
        local val = self.GD.buffVal_31;
        local count = cond:getNumber();
        local icon = 0;
        local num = val - (itemCount * 10);
        if num <= self.GD.evasionMin then
            num = self.GD.evasionMin;
        end

        if num == 0 then
            count = 0;
            icon = 0;
            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
            local countBuff = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID);
            if countBuff ~= nil then
                self.gameUnit:getTeamUnitCondition():removeCondition(countBuff);
            end
            return;
        elseif num > 0 then
            count = math.floor(num / 10);
            icon = 16;
        end

        --カウントが10以下の場合はカウントバフ用に切り替えて表示する
        if count < 10 then
            icon = 0;
            self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3]);
            local buff = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID);
            if buff ~= nil then
                buff:setNumber(count);
            end
        end

        cond:setValue(num);
        cond:setNumber(count);
        cond:setThumbnailID(icon);
        megast.Battle:getInstance():updateConditionView();
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        self.hpSkill = 6;
        self.gameUnit:addSP(100);
        self.timerDamageRate = self.GD.timerDmgVal;
        self:showMessage(self.TIMER_MESSAGE_LIST);
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex, 1, 0, true);
        self.timeIndex = nil;
        self.voiceFlg = true;
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local FLG = 0
        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2
        end

        if FLG == 2 then
            self.timeSpeed = 0
        elseif FLG == 1 then
            self.timeSpeed = 1
        else
            self.timeSpeed = 1
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_PB_back" then
        event.unit:addOrbitSystem("PB_back",0);
        self.voiceFlg = false;
    end
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("2-skill1");
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("2-skill2");
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1]);
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            if cond:getNumber() < self.BUFF_BOX_LIST[1].MAX then
                self:showMessage(self.ATTACK3_MESSAGE_LIST);
            end
        end
    end

    self.fromHost = false;
        self:attackActiveSkillSetter(event.unit,event.index);
    if self.afterSkillFLG then
        self:refresh(self.gameUnit);
        self.gameUnit:setInvincibleTime(0);
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
        self.timerDamageRate = 1;
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
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

    if event.index == 1 then
        self:execSkill1(event.unit);
    elseif event.index == 2 then
        self:execSkill2(event.unit);
    elseif event.index == 3 then
        self:execSkill3(event.unit);
    elseif event.index == 5 then
        self.voiceFlg = false;
    elseif event.index == 6 then
        event.unit:setNextAnimationName("skill5_PB");
        event.unit:setNextAnimationEffectName("2-skill5_PB");
        self.voiceFlg = true;
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
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL);
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

function class:execSkill1(unit)
end

function class:execSkill2(unit)
end

function class:execSkill3(unit)
end

function class:checkTargetUnit()
    local target = nil;
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            target = myTeamUnit;
            break;
        end
    end
    return target;
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy);
    event.value = event.value * self.timerDamageRate;
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeBreakeDamageValue //
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    event.value = event.value * self.timerDamageRate;
    return event.value;
end

----// takeBreake //
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
    self:showMessage(self.DEAD_MESSAGE_LIST);
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex, 1, 0, true);
        self.timeIndex = nil;
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
                if not unit:isBreak() then
                    self:execTrigger(index);
                end
            else
                self:execTrigger(index);
            end
        end
    end
end

function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP], true);
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

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1;
end

function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
end

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

function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit);
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
end

function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    event.value = event.value * self.timerDamageRate;
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

class:publish();

return class;
