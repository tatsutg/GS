--@additionalEnemy,200260905
--@additionalItem,108611500
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ニーア", version=1.3, id=200260904});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    --SKILL1 = 2,
    --SKILL2 = 3,
    SKILL3 = 5,
    SKILL4 = 6
}

class.ANIMATIONS = {
    [2] = {ANIMATION = "skill1",EF = "3-skill1"},
    [3] = {ANIMATION = "skill2",EF = "3-skill2"},
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.DEAD_BUFF_LIST = {
        {
            ID = 2002609041,
            BUFF_ID = 13, -- 攻撃力
            VALUE = 100,
            DURATION = 99999,
            ICON = 3,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        {
            ID = 2002609042,
            BUFF_ID = 17,   -- 与ダメ
            VALUE = 200,
            DURATION = 99999,
            ICON = 26
        }
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下・HP吸収耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル無効・庇うキラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ここがお前の墓場よ",COLOR = Color.magenta})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "さぁ醜態を晒しなさい",COLOR = Color.magenta})
    }
    self.REVERSAL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.REVERSAL_MESSAGE1 or "奥義ゲージ自然上昇効果反転",COLOR = Color.red})
    }
    self.LINK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LINK_MESSAGE1 or "スキだらけよ！",COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.LINK_MESSAGE2 or "ぶっ潰れろ！",COLOR = Color.magenta})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "…やりやがったな",COLOR = Color.magenta})
    }
    self.END_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.END_MESSAGE1 or "認めない、こんな…結末…",COLOR = Color.magenta})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0,
            used = false
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

function class:hp50(status)
    if status == "use3" then
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.gameUnit:addSP(100)
    end
end

function class:hp0(status)
    if status == "use3" then
    end
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.BLACK_LIST = {10116600,10121600,10181600,10189600,10222600,10229600,20183600,20191600,20203600,20203700,20263600,20287600,20722600,40072100,40072200,40072300,40072400,40072500,40072600,40072700,40072800,40072900,40073000,40073100,40073200,40073300,40073400,40073500,40073600,40073700,40073800,40073900,40074000,40074100,40074200,40074300,40074400,40074500,40074600,40074700,40074800,40074900,40075000,40088000,40089000,40090000,40091000,40092000,40093000,40094000,40095000,40096000,40097000,40126700,40231200,50072100,50072200,50072300,50072400,50072500,50072600,50072700,50072800,50072900,50073000,50073100,50073200,50073300,50073400,50073500,50073600,50073700,50073800,50073900,50074000,50074100,50074200,50074300,50074400,50074500,50074600,50074700,50074800,50074900,50075000,50088000,50089000,50090000,50091000,50092000,50093000,50094000,50095000,50096000,50097000,50184200,50200900,50207000,300355100,300423100,300441100,300557100,300648100,300702100,300703100,305007100,305030100}
class.BLACK_LIST_TYPE = {11}
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
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

    self.item = event.unit:setItemSkill(0,108611500)

    self.renkeiTimer = 0
    self.RENKEI_SPAN = 8.3

    self.gradIndex = nil
    for i = 0, 6 do
        local unit = event.unit:getTeam():getTeamUnit(i)
        if unit ~= nil and unit:getEnemyID() == 200260905 then
            -- グラードをいったん殺しておく
            -- なお、グラードはバトルマスタでニーアより先に配置する必要がある
            event.unit:getTeam():deadUnit(i)
            self.gradIndex = i
        end
    end

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    event.unit:takeItemSkill(0)
    self.item:setCoolTimer(0)

    self.battleStart = true
    self.summonTimer = 0
    self.SPAN = 30
    self.ENEMY_ID = 200260902
    return 1
end

-----------------------------------------------------------------------------------
---- waveEnd
-----------------------------------------------------------------------------------
--function class:waveEnd(event)
--    self.showMessage(self.END_MESSAGE_LIST)
--    return 1
--end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:HPTriggersCheck(event.unit)
    self:checkSummon(event.unit,event.deltaTime)
    self:checkEnd(event.unit,event.deltaTime)
    self:checkTeam(event.unit)

    return 1
end

function class:checkSummon(unit,deltaTime)
    if not self:getIsHost() or not self.battleStart then return end

    if self.summonTimer < self.SPAN then
        self.summonTimer = self.summonTimer + deltaTime
        return
    end
    self.summonTimer = self.summonTimer - self.SPAN
    self:summon(unit,self.ENEMY_ID,5)
end

function class:checkEnd(unit,deltaTime)
    if not self.isDead then return end

    if self.isEnd then
        if self.renkeiTimer < self.RENKEI_SPAN then
            self.renkeiTimer = self.renkeiTimer + deltaTime
            unit._ignoreBorder = true;
            unit:setInvincibleTime(0.5)
            unit:setPosition(-1000,0)
            return
        end

        self.isEnd = false
        self:getAncestorUnit(unit):setPosition(-250,0)
        --self:summon(self:getAncestorUnit(unit),200260905,6)
        if self.gradIndex ~= nil then
            -- グラードを蘇生
            unit:getTeam():reviveUnit(self.gradIndex)
        end
        self.isSummoned = true
        self:getAncestorUnit(unit):takeAttack(1)
    end
end

function class:checkTeam(unit)
    if self.isSummoned and not self:findUnit(unit,109) and not self.isUp then
        self.isUp = true
        self.spValue = 50
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    local rate = 1 / 7
    if event.spineEvent == "2orbitSnake1_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake2_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake3_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake4_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake5_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end

    if event.spineEvent == "2orbitSnake6_6" then
        local orbit = event.unit:addOrbitSystemWithFile("10110ef",event.spineEvent)
        orbit:setDamageRateOffset(rate)
        orbit:setBreakRate(rate)
    end
    return 1;
end

function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isEnd then
        return 0
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeBreakeDamageValue
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.isEnd then
        return 0
    end
    return event.value
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.isDead and not self:getIsHost() then
        event.unit:setHP(1)
        return 0
    end

    if not self.isDead and self:getIsHost() then
        self:deadAction()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,1);
        return 0
    end

    if not self.isRealDead and not self:getIsHost() then
        event.unit:setHP(1)
        return 0
    end

    if self:getIsHost() then
        self:deadAction2()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1);
    end
    return 1
end

function class:deadAction()
    self.isDead = true
    self.isEnd = true
    local orbit = self.gameUnit:addOrbitSystemWithFile("link_109110","linkSkill_all")
    orbit:setPosition(0,0);
    orbit:setActiveSkill(self.ACTIVE_SKILLS.SKILL4);
    self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * 0.7)
    self:showMessage(self.LINK_MESSAGE_LIST)
    self.gameUnit:removeHpMarker(self.hpMarkers[0])
end

function class:receive5(args)
    self:deadAction()
    return 1
end

function class:deadAction2()
    self.isRealDead = true
    local teamUnit = self:findUnit(self.gameUnit,109)
    if teamUnit ~= nil then
        self:execAddBuff(teamUnit,self.DEAD_BUFF_LIST[1])
        self:execAddBuff(teamUnit,self.DEAD_BUFF_LIST[2])
        self:showMessage(self.DEAD_MESSAGE_LIST)
    else
        self:showMessage(self.END_MESSAGE_LIST)
    end
end

function class:receive6(args)
    self:deadAction2()
    self.gameUnit:setHP(0)
    return 1
end


function class:excuteAction(event)
    if self.isEnd then
        event.unit:takeIdle()
        return 1
    end
    return 1
end

function class:findUnit(unit,unitID)
    for i = 0, 7 do
        local localUnit = unit:getTeam():getTeamUnit(i)
        if localUnit ~= nil and localUnit:getBaseID3() == unitID then
            return localUnit
        end
    end
    return nil
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
    self:addSP(event.unit)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index ~= 1 then
        event.unit:setNextAnimationName(self.ANIMATIONS[event.index].ANIMATION)
        event.unit:setNextAnimationEffectName(self.ANIMATIONS[event.index].EF)
    end
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    --if attackIndex == 1 then
    unit:takeAttack(attackIndex);
    --elseif attackIndex == 2 then
    --    self.attackCheckFlg = false
    --    self.skillCheckFlg = true;
    --    unit:takeSkill(1);
    --    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1);
    --    return 0;
    --elseif attackIndex == 3 then
    --    self.attackCheckFlg = false
    --    self.skillCheckFlg = true;
    --    unit:takeSkill(2);
    --    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,2);
    --    return 0;
    --end
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
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index == 3 then
        event.unit:setDamageRateOffset(1/7)
        event.unit:setBreakRate(1/7)

        self:removeCondition(36)
        self:showMessage(self.REVERSAL_MESSAGE_LIST)
    end
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
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
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
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

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
    self.TRIGGERS[args.arg].used = true
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

function class:receive4(args)
    local enemyID = math.floor(args.arg / 10)
    local i = args.arg % 10
    self.gameUnit:getTeam():addUnit(i,enemyID);  --指定したインデックスの位置に指定したエネミーIDのユニットを出す
    return 1
end

--===================================================================================================================
-- エネミー召喚
--===================================================================================================================
function class:summon(unit,enemyID,finish)
    if not self:getIsHost() then return end

    for i = 0, finish do
        if i ~= self.gradIndex and unit:getTeam():getTeamUnit(i) == nil then
            unit:getTeam():addUnit(i,enemyID);  --指定したインデックスの位置に指定したエネミーIDのユニットを出す
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,(enemyID*10) + i);
            return
        end
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.FUNC ~= nil then buffBox.FUNC(buff) end
end


function class:removeCondition(id)
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if teamUnit ~= nil then
            self:removeConditionAll(teamUnit,id)
        end
    end
end

function class:removeConditionAll(unit,id)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then
        return
    end

    local uId = 2002609044
    local cList = {}
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil and cond:getThumbnailID() == id and cond:getValue() >= 1 and not self:isBlacklist(cond:getID()) and not self:isBlacklistType(cond:getConditionTypeAsInt()) then
            table.insert(cList,cond)
        end
    end

    for i,cond in pairs(cList) do
        if cond:getConditionTypeAsInt() == 237 then
            local buff = nil
            buff = unit:getTeamUnitCondition():addCondition(uId + i,237,cond:getValue()*-1,30,213);
            buff:setEffectMin(cond:getEffectMin())
        else
            self:execAddBuff(unit,{ID = uId + i,BUFF_ID = 10,VALUE = cond:getValue() * -1,ICON = 213,DURATION = 30})
        end
        unit:getTeamUnitCondition():removeCondition(cond)
        unit:resumeUnit()
    end
    unit:resumeUnit()
end

function class:isBlacklist(id)
    for _,v in pairs(self.BLACK_LIST) do
        if v == id then
            return true
        end
    end
    return false
end

function class:isBlacklistType(id)
    for _,v in pairs(self.BLACK_LIST_TYPE) do
        if v == id then
            return true
        end
    end
    return false
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


function class:other(event)
    --ブレイク時間
    local time = event.unit.m_breaktime
end

class:publish();

return class;