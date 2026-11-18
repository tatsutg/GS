local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="真EX_超シモン", version=2.8, id=2081780});
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
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL3 = 4,
    SKILL5 = 5
}

class.cutInSkill = {
    [5] = 4
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
            MAX = 10
        },
        [2] = {
            ID = 200069302,
            BUFF_ID = 31, --回避率UP
            VALUE = self.GD.buffVal_31,
            DURATION = 999999,
            ICON = 16,
            MAX = 15
        },
        [3] = {
            ID = 200069303,
            BUFF_ID = 0, --回避率UP MAX表示用
            VALUE = 0,
            DURATION = 999999,
            ICON = 17,
            MAX = 1
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
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "裁きの刻だ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "行動速度アップ", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "引き際か…", COLOR = Color.magenta}),
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
            self.saveBP = self.gameUnit:getBurstPoint() * 0.5;
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setAttackDelay(self.GD.hp50AttackDelay);
        -- self.gameUnit:setInvincibleTime(15);
        -- self:refresh(self.gameUnit);
        -- self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[2]);
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 9,
        hp50AttackDelay = 7,
        hitStop = 100,
        buffVal_17 = 5,
        buffVal_31 = 50,
        evasionMin = -150
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

    self.infoCount = 0;
    self.itemCount = 0;
    self.itemUnitList = {};
    self:initItemCheck();
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
    ---プレイヤーPTの装備使用ギミック
    self:useItemCheck();
    event.unit:setReduceHitStop(self.GD.hitStop,1);
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
        elseif num > 0 then
            count = math.floor(num / 10);
            icon = 16;
        else
            count = math.floor(num / 10 * -1);
            icon = 17;
            if count >= self.BUFF_BOX_LIST[2].MAX then
                count = self.BUFF_BOX_LIST[2].MAX;
                icon = 0;
                --カウント表示バグ対策のため、回避率アップのMAX表示用のバフを付与
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3]);
            end
        end

        cond:setValue(num);
        cond:setNumber(count);
        cond:setThumbnailID(icon);
        megast.Battle:getInstance():updateConditionView();
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_PB_back" then
        event.unit:addOrbitSystem("PB_back",0);
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
        self.infoCount = self.infoCount + 1;
        if self.infoCount <= 10 then
            self:showMessage(self.ATTACK3_MESSAGE_LIST);
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit);
        self.gameUnit:setInvincibleTime(0);
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    elseif not self.afterSkillFLG then
        self:addSP(event.unit);
    end

    self:attackActiveSkillSetter(event.unit,event.index);
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

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;

    if event.index == 1 then
        self:execSkill1(event.unit);
    elseif event.index == 2 then
        self:execSkill2(event.unit);
    end

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

function class:execSkill1(unit)
    -- 奥義4：Lua効果なし
end

function class:execSkill2(unit)
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
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeBreakeDamageValue //
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
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
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST);
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
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

class:publish();

return class;
