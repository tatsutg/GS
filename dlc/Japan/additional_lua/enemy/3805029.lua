local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="38章_真EX極_ギルドマスター・レイアス", version=2.8, id=3805029});
class:inheritFromUnit("unitBossBase");

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL4 = 5,
    SKILL5 = 6,
    SKILL6 = 7
}

class.cutInSkill = {
    [4] = 4,
    [5] = 4,
    [6] = 4
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 38050291,
            BUFF_ID = 17,
            VALUE = self.GD.darkOnBuffVal_17,
            DURATION = 999999,
            ICON = 27
        },
        [2] = {
            ID = 38050291,
            BUFF_ID = 17,
            VALUE = self.GD.darkOffBuffVal_17,
            DURATION = 999999,
            ICON = 26
        },
        [3] = {
            ID = 38050292,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 139
        },
        [4] = {
            ID = 38050292,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 20
        },
        [5] = {
            ID = 38050293,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 42
        }
    }
end

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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "全力でいく！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下・闇属性耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "与ダメージ・被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "暗闇状態中、与ダメージ・被ダメージダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "人族・光属性ユニットからの被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "輝け、意志の剣──", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "全力全開だ！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "攻撃力・スーパークリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "被ダメージ軽減・一定時間経過で強力なスターダスト・ブレイド発動！", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "うおおおおおおお！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ぐああああ！！", COLOR = Color.yellow})
    }
end

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
        end
    end
end

function class:hp75(status)
    if status == "use3" then
        -- self.gameUnit:setInvincibleTime(15)
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP75_MESSAGE_LIST)
        self.cutInFLG = true
        self.hp75Flg = true
    end
end

function class:hp50(status)
    if status == "use3" then
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(30)
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint() + self.GD.hp50AddSP
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:deBuffRefresh(self.gameUnit)
    end
end

function class:hp25(status)
    if status == "use3" then
        self:refresh(self.gameUnit)
        -- self.gameUnit:setInvincibleTime(999999)
        self.saveBP = self.gameUnit:getBurstPoint()
        self:showMessage(self.HP25_MESSAGE_LIST)
        self.gameUnit:setBurstPoint(0)
        self.waitingMode = true
        self.subBarFlg = true
        self.hpSkill = 6;
        self:deBuffRefresh(self.gameUnit)
    end
end

function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        hp50AddSP = 80,
        hp25AddSP = 40,
        attackDelay = 6,
        hitStop = 100,

        darkOnBuffVal_17 = -50,
        darkOffBuffVal_17 = 100,

        darkAtkTDmgVal = 0.05,
        darkBuffTDmgVal_1 = 0.5,
        darkBuffTDmgVal_2 = 1.2,
        TriggerTDmgVal = 0.2,
        exGaugeHPRate = 0.5,
        addSpTimer = 3,
        timeAddSP = 20
    })
    self:dump(self.GD)

    self.fromHost = false
    self.gameUnit = event.unit

    self.spValue = self.GD.addSP
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay)
    end

    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.cutInFLG = false
    event.unit:setSPGainValue(0)
    event.unit:setSkillInvocationWeight(0)

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.hp75Flg = false

    --サブHP表示用
    self.subBarFlg = false;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * self.GD.exGaugeHPRate;
    self.damage = 0;---サブバー表示時のダメージ

    self.battleTime = 0
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[5]);
    return 1;
end

function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end

    ---暗闇でのバフ監視
    local darkCond = self.gameUnit:getTeamUnitCondition():findConditionWithType(93)
    if darkCond ~= nil then
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[4])
    else
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[3])
    end

    --EXゲージ
    if self.subBarFlg then
        self.battleTime = self.battleTime + event.deltaTime
        if self.battleTime >= self.GD.addSpTimer then
            self.battleTime = 0
            event.unit:addSP(self.GD.timeAddSP);
        end

        if event.unit:getUnitState() ~= kUnitState_idle then
            event.unit:takeIdle()
            event.unit:takeAnimation(0,"idle",true);
        end
        self:subBarControll(event.unit,self.damage)
    end

    event.unit:setReduceHitStop(self.GD.hitStop, 1)
    return 1
end

function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    --確認用info
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.damage = 0;
        self.hpSkill = 5;
        self.gameUnit:addSP(100)
        self:showMessage(self.SKILL_MESSAGE_LIST,1);
    end
end

function class:run(event)
    if event.spineEvent == "Library_orbit" then
        local orbit = event.unit:addOrbitSystem("orbit",0)
        orbit:setDamageRateOffset(0.3)
        orbit:setBreakRate(0.3)
    end
    return 1
end

function class:takeIdle(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:receive6(args)
    return 1
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackReroll(event.unit)
    end
    self.attackCheckFlg = false
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    self.hp75Flg = false
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("2-skill1");
    end

    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    self.fromHost = false
    self:attackActiveSkillSetter(event.unit,event.index)
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    elseif not self.addSpSkipFLG then
        if not self.subBarFlg then
            self:addSP(event.unit)
        end
    end
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    unit:takeAttack(tonumber(attackIndex))
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex))
    return 0
end

function class:addSP(unit)
    unit:addSP(self.spValue)
    return 1
end

function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        return self:skillReroll(event.unit)
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    if self.cutInFLG then
       self.cutInFLG = false;
       event.unit:takeSkillWithCutin(event.index,0);
       return 0;
    end

    if self.subBarFlg then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.damage = 0;
        self.spValue = self.GD.hp25AddSP;
        self:showMessage(self.SKILL_MESSAGE_LIST);
    end

    if event.index == 3 then
        event.unit:setDamageRateOffset(0.7);
        event.unit:setBreakRate(0.7);
    elseif event.index == 4 then
        event.unit:setNextAnimationName("skill5");
        event.unit:setNextAnimationEffectName("2-skill5");
    elseif event.index == 6 then
        event.unit:setNextAnimationName("skill5");
        event.unit:setNextAnimationEffectName("2-skill5");
    end

    self.skillCheckFlg = false
    self.cutInFLG = false
    self.addSpSkipFLG = true
    self.fromHost = false
    self:skillActiveSkillSetter(event.unit,event.index)
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
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex])
    else
        unit:takeSkill(tonumber(skillIndex))
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex))
    return 0
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index])
    else
        unit:takeSkill(index)
    end
end

function class:execSkill3(unit)
end

function class:execSkill4(unit)
end

function class:execSkill5(unit)
end

function class:execSkill6(unit)
end

function class:execSkill7(unit)
end

function class:attackDamageValue(event)
    return event.value
end

function class:attackDamageValue_OrbitSystem(event)
    return event.value
end

function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    --闇ダメージ補正
    local element = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    if element == 5 then
        event.value = event.value * self.GD.darkAtkTDmgVal
    end
    --暗闇補正
    local darkCond = self.gameUnit:getTeamUnitCondition():findConditionWithType(93)
    if darkCond ~= nil then
        event.value = event.value * self.GD.darkBuffTDmgVal_1
    else
        event.value = event.value * self.GD.darkBuffTDmgVal_2
    end
    --HPトリガー
    if self.hp75Flg then
        event.value = event.value * self.GD.TriggerTDmgVal
    end

    --EXゲージ
    if self.subBarFlg then
        self.damage = self.damage + event.value
        event.value = 1
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end
    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    self.breakFlg = true
    return 1
end

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
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR)
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR)
    end
end

function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                self:execTrigger(index)
            end
        end
    end
end

function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return
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
    return megast.Battle:getInstance():isHost()
end

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
    end
    return 1
end

function class:receive8(args)
    return 1
end

function class:execAddBuff(unit,buffBox)
    local buff = nil
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID)
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond)
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT)
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY)
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON)
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
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID)
        buff:setPriority(buffBox.PRIORITY)
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
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount])
    local attackIndex = string.gsub(attackStr,"ATTACK","")
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr,"SKILL","")
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

function class:refresh(unit)
    local badStatusIDs = {89,91,96}
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i]
        local flag = true
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID)
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond)
            else
                flag = false
            end
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

class:publish()

return class