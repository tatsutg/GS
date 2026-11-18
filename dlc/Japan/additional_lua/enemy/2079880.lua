--@additionalEnemy,2079881
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="俺レベ_真EX_イグリット", version=2.6, id=2079880});
class:inheritFromUnit("unitBossBase");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2  = 3,
    SKILL3  = 4,
    SKILL5  = 5,
}

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK2 = 100 },
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
    }
}

---SKILL3(奥義5)のみ超奥義カットイン
class.cutInSkill = {
    [3] = 1,
    [5] = 4,
}

function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE  = messageBox.MESSAGE  or "メッセージ",
        COLOR    = messageBox.COLOR    or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {}
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "光・闇属性ユニットからの被ダメージアップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "いい圧力だ…！",             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "水篠 旬が加勢",       COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE3 or "一定時間経過毎にさらに追い打ち",       COLOR = Color.yellow}),
    }
    self.HP10_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE1 or "攻撃力アップ", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "まぐれ、かもな。", COLOR = Color.magenta}),
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag          = "HP_FLG",
            action       = function(status) self:hp50(status) end,
            HP           = 50,
            used         = false,
            isEnableSkip = false
        },
        [2] = {
            tag          = "HP_FLG",
            action       = function(status) self:hp10(status) end,
            HP           = 10,
            used         = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers   = {}
    for index, trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[trigger.HP] = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
            if trigger.isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[trigger.HP], 0, 255, 255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[trigger.HP],
                    "battle_marker_hp_marker_white_1.png",
                    "battle_marker_hp_marker_white_2.png",
                    "unit/animation/battle_marker_white.plist")
            end
        end
    end
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP      = 20,
        attackDelay = 9,
        hitStop    = 100,

        tgTimer    = 20,
        tgLimit    = 99999,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX     = 0,
        tgPosY     = 0,
        tgScale    = 1.0,

        hp10DmgRate = 0.2,
        hp50SeveBPRate = 0.5,
    })
    self:dump(self.GD)

    self.fromHost  = false
    self.gameUnit  = event.unit

    self.spValue   = self.GD.addSP
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay)
    end

    self.attackCheckFlg = false
    self.skillCheckFlg  = false
    self.cutInFLG       = false
    event.unit:setSPGainValue(0)
    event.unit:setSkillInvocationWeight(0)

    self.hpMarkers = {}
    self.isRage    = false
    self.isFury    = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG  = true
    self.breakSkip     = false
    self.hpSkill       = 0
    self.saveBP        = 0

    self.lastSkillFLG  = false
    self.deadFlg       = false
    self.hp10DmgFLG    = false

    self.timeIndex     = nil
    self.timeSpeed     = 1
    self.shunID        = 2079881

    return 1
end

function class:startWave(event)
    return 1
end

function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop, 1)

    if self.timeIndex ~= nil then
        self:extraTimerOperation(event.unit)
    end
    return 1
end

function class:run(event)
    return 1
end

function class:addSP(unit)
    unit:addSP(self.spValue)
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

    self.hp10DmgFLG    = false;
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
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

    self.skillCheckFlg = false
    self.cutInFLG      = false
    self.addSpSkipFLG  = true
    self.fromHost      = false
    self:skillActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex    = self.hpSkill
        self.hpSkill  = 0
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
    ---HP10%トリガー発動中は被ダメージ0.2倍
    if self.hp10DmgFLG then
        event.value = event.value * self.GD.hp10DmgRate
    end
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
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
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

function class:dead(event)
    megast.Battle:getInstance():waveEnd(true);
    self:showMessage(self.DEAD_MESSAGE_LIST)
    local myTeam = megast.Battle:getInstance():getTeam(false)
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i)
        if u ~= nil then
            if u:getEnemyID() == self.shunID then
                u:getTeam():deadUnit(u:getIndex());
            end
        end
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end


function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

---HP50%：水篠旬召喚、エクストラタイマー開始、奥義4発動（カットインなし）、奥義ゲージ50%引き継ぎ
function class:hp50(status)
    if status == "use3" then
        self:summon(self.gameUnit, self.shunID)
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(
            self.GD.tgTimer,    self.GD.tgLimit,
            self.GD.tgIconNum1, self.GD.tgIconNum2,
            self.GD.tgPosX,     self.GD.tgPosY, self.GD.tgScale)
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)

        ---SKILL2(奥義4)をカットインなしで発動
        self.hpSkill  = 3
        self.saveBP   = math.floor(self.gameUnit:getBurstPoint() * self.GD.hp50SeveBPRate)
        self.gameUnit:addSP(100)
        -- self.gameUnit:setInvincibleTime(15)
        self:refresh(self.gameUnit)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

---HP10%：奥義5発動（超奥義カットイン）、発動後戦闘不能
function class:hp10(status)
    if status == "use3" then
        ---SKILL3(奥義5)を超奥義カットインで発動
        self.hpSkill      = 5
        self.saveBP       = 0
        self.gameUnit:addSP(100)
        -- self.gameUnit:setInvincibleTime(30)
        self:refresh(self.gameUnit)
        self.lastSkillFLG = true
        self.hp10DmgFLG   = true
        self:showMessage(self.HP10_MESSAGE_LIST)
    end
end

---ボスブレイク中・水篠旬行動中はタイマー停止
function class:extraTimerOperation(unit)
    if self.timeIndex == nil then return end
    local speed = 1
    if unit:isBreak() or unit:getInvincibleTime() > 0 then
        speed = 0
    else
        local shunUnit = self:findShunUnit()
        if shunUnit ~= nil then
            speed = 0
        end
    end
    if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex, speed)
        self.timeSpeed = speed
    end
end

---タイマー1周ごとに水篠旬がinモーション→奥義2→退場
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        if megast.Battle:getInstance():isHost() then
            self:summon(event.unit, self.shunID);
        end
    end
    return event.count
end

function class:findShunUnit()
    local myTeam = megast.Battle:getInstance():getTeam(false)
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i)
        if u ~= nil and u:getEnemyID() == self.shunID then
            return u
        end
    end
    return nil
end

function class:summon(unit, unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i, unitID)
                break
            end
        end
    end
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
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
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


class:publish();

return class;