local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="37章_EX2_十二代目ミズキ", version=1.3, id=3705023})
class:inheritFromUnit("unitBossBase")

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 4,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "七天最終奥義「水天彷彿」",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B_02",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "シンカイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL4 = 4,
    SKILL5 = 5
}

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 100 },
        { ATTACK1 = 100 },
        { ATTACK2 = 100 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL4 = 100 }
    }
}

class.cutInSkill = {
    [5] = 1
}

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 6,
        hitStop = 100
    })
    self:dump(self.GD)

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

    self.hpMarkers = {}
    self.addSpSkipFLG = true
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.lastSkillFLG = false
    self.deadFlg = false
    self.fromHost = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self:showMessage(self.START_MESSAGE_LIST)

    self.AURA_INTERVAL = 99999
    self.isAura = false
    self.timer = 0
    self.shinMode = false
    self.vanishFLG = false
    self.emptyFLG = false
    self:setSurfaceBoxList()
    return 1
end

function class:startWave(event)
    return 1
end

function class:update(event)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop, 1)
    return 1
end

function class:auraPosition(unit)
    if self.aura == nil then
        return
    end

    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
    if self.isAura then
        ---カイガン
        -- unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    end
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            self.isAura = false
            self.timer = 0
            self:setBuffBoxList()
            -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
            --unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
            self.aura:takeAnimation(0,"empty",true);
            self.shinMode = false
            self.emptyFLG = false
        else
            self.timer = self.timer + deltaTime
            if self.vanishFLG and not self.emptyFLG then
                self.aura:takeAnimation(0,"empty",true);
                self.emptyFLG = true
            elseif not self.vanishFLG and self.emptyFLG then
                self.emptyFLG = false
                if self.shinMode then
                    self.aura:takeAnimation(0,"Kaigan2_loop",true);
                else
                    self.aura:takeAnimation(0,"Kaigan_loop",true);
                end
            end
        end
    end
end

function class:run(event)
    if event.spineEvent == "md2Start" then
        self:setAura(event.unit)
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"Kaigan_loop",true);
    end
    if event.spineEvent == "shinStart" then
        self:shinSetAura(event.unit)
    end
    if event.spineEvent == "loopStart2" then
        self.aura:takeAnimation(0,"Kaigan2_loop",true);
    end
    if event.spineEvent == "auraReturn" then
        self.vanishFLG = false
    end
    if event.spineEvent == "auraVanish" then
        self.vanishFLG = true
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:shinSetAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan2_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:loopStart1(unit)
    self.vanishFLG = false
    if self.loopStart1FLG then
        if self.shinMode then
            self:shinSetAura(unit)
        else
            self:setAura(unit)
        end
    end
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end
---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1")
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2")
    end

    self.fromHost = false
    self:attackActiveSkillSetter(event.unit, event.index)

    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    else
        self:addSP(event.unit)
    end
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
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index, 1)
        return 0
    end

    if event.index == 2 then
        self:execSkill2(event.unit)
    elseif event.index == 3 then
        self:execSkill3(event.unit)
    elseif event.index == 4 then
        event.unit:setNextAnimationName("skill3b")
        event.unit:setNextAnimationEffectName("skill3b")
    elseif event.index == 5 then
        if not self.isAura then
            self.isAura = true
        end
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("shin_skill3b")
        self:execSkill5(event.unit)
    end

    self.skillCheckFlg = false
    self.cutInFLG = false
    self.addSpSkipFLG = true
    self.fromHost = false
    self:skillActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:execSkill2(unit)
end

function class:execSkill3(unit)
end

function class:execSkill5(unit)
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    end
    unit:takeAttack(tonumber(attackIndex))
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, tonumber(attackIndex))
    return 0
end

function class:takeAttackFromHost(unit, index)
    self.fromHost = true
    unit:takeAttack(index)
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL)
    end
    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex), self.cutInSkill[skillIndex])
    else
        unit:takeSkill(tonumber(skillIndex))
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, tonumber(skillIndex))
    return 0
end

function class:takeSkillFromHost(unit, index)
    self.fromHost = true
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index, self.cutInSkill[index])
    else
        unit:takeSkill(index)
    end
end

function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

function class:takeBreake(event)
    for i = 1, table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP], true)
    end
    return 1
end

function class:addSP(unit)
    unit:addSP(self.spValue)
    return 1
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "蹴散らす！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "イマリの願いよ", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "カイガン：攻撃力アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ぐああああああ！！", COLOR = Color.cyan})
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
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index, trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP], 0, 255, 255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP], "battle_marker_hp_marker_white_1.png", "battle_marker_hp_marker_white_2.png", "unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        -- self.gameUnit:setInvincibleTime(15)
        -- self:refresh(self.gameUnit)
        self:showMessage(self.HP50_MESSAGE_LIST)
        -- self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
    end
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 200069301,
            BUFF_ID = 13,
            VALUE = 20,
            DURATION = 999999,
            ICON = 3
        }
    }
end

function class:showMessage(messageBoxList, index, targetUnit)
    if index == nil then
        self:showMessageAll(messageBoxList, targetUnit)
        return
    end
    self:execShowMessage(messageBoxList[index], targetUnit)
end

function class:showMessageAll(messageBoxList, targetUnit)
    for _, messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox, targetUnit)
    end
end

function class:execShowMessage(messageBox, targetUnit)
    local msg = messageBox.MESSAGE
    if targetUnit ~= nil then
        msg = string.format(msg, targetUnit:getUnitName())
    end
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(msg, messageBox.DURATION, messageBox.COLOR)
    else
        summoner.Utility.messageByEnemy(msg, messageBox.DURATION, messageBox.COLOR)
    end
end

function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100
    for index, trigger in pairs(self.HP_TRIGGERS) do
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

function class:execTrigger(index, receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP], true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID, 5, index)
        return
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    self.TRIGGERS[index].action(action)
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID, receiveNumber, index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost()
end

function class:adjustHpFlg(unit, value)
    local anotherHp = unit:getHP() - value
    for _, trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit, stopBorder, value)
        end
    end
    return value
end

function class:calcDamageValue(unit, border, value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

function class:execAddBuff(unit, buffBox)
    local buff = nil
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON, buffBox.EFFECT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON)
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
    end
end

function class:refresh(unit)
    local badStatusIDs = {89, 91, 96}
    for i = 1, table.maxn(badStatusIDs) do
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
            if count > 100 then break end
        end
    end
end

function class:movePatternState(SET_LIST, stateBox)
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
    local attackIndex = string.gsub(attackStr, "ATTACK", "")
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr, "SKILL", "")
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



class:publish()
return class