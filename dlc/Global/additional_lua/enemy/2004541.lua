local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹木妖狐「憂月」", version=1.8, id=2004541})
class:inheritFromUnit("unitBossBase");

--[[
ATTACK1,5 火の玉突進
ATTACK2,6 噴火
ATTACK3,7 剣撃
]]

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    FIRE_1 = {
        { ATTACK3 = 50, ATTACK1 = 50 },
        { ATTACK2 = 50},
        { ATTACK3 = 50, ATTACK1 = 50 },
        { ATTACK3 = 50, ATTACK1 = 50 }
    },
    DARK_1 ={
        { ATTACK7 = 50, ATTACK5 = 50 },
        { ATTACK6 = 50},
        { ATTACK7 = 50, ATTACK5 = 50 },
        { ATTACK7 = 50, ATTACK5 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    FIRE_1 = {
        { SKILL4 = 50 }
    },
    DARK_1 = {
        { SKILL5 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 3,
    ATTACK3 = 1,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 4,
    SKILL4 = 7,
    SKILL5 = 8
}

function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            STOP_BORDER = self.gameUnit:getCalcHPMAX() * 0.3
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

function class:hp30(status)
    if status == "use3" then
        self.spValue = 40;
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
        self:showMessage(self.HP30_MESSAGE_LIST)
        self.gameUnit:takeAnimation(0,"skill1",false)
        self.gameUnit:takeAnimationEffect(0,"1-skill1",false)
        self.gameUnit:setInvincibleTime(8)
        self.countStart = true
    end
end


function class:change()
    --if self.isAwaken then self:awaken() else self:normal() end
    self:awaken()
    --self.gameUnit:takeGrayScale(0.01)
    self.isNega = true
    self.negaTimer = 0

    for i = 0,3 do
        local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
            u:takeGrayScale(0.01)
        end
    end
end

function class:awaken()
    self.isAwakened = true
    self.gameUnit:setSkin("rage")
    self:initAttackWeight({DARK_1 = 100})
    self:initSkillWeight({DARK_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,241,35,177);
    megast.Battle:getInstance():setBossCounterElement(5);
    self.gameUnit:setElementType(5);
    --self:removeCondition(self.gameUnit,self.FIRE_BUFF_BOX[1].ID)
    --self:removeCondition(self.gameUnit,self.FIRE_BUFF_BOX[2].ID)
    --self:addBuff(self.gameUnit,self.DARK_BUFF_BOX)
    --self:showMessage(self.DARK_MESSAGE_LIST)
end

function class:normal()
    self.isAwakened = false
    self.gameUnit:setSkin("normal")
    self:initAttackWeight({FIRE_1 = 100})
    self:initSkillWeight({FIRE_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,255,255,255);
    megast.Battle:getInstance():setBossCounterElement(1);
    self.gameUnit:setElementType(1);
    --self:removeCondition(self.gameUnit,self.DARK_BUFF_BOX[1].ID)
    --self:removeCondition(self.gameUnit,self.DARK_BUFF_BOX[2].ID)
    --self:addBuff(self.gameUnit,self.FIRE_BUFF_BOX)
    --self:showMessage(self.FIRE_MESSAGE_LIST)
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or  "瘴気があたりを包む",
                             COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or  "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or  "ダメージ無効化無効"})
    }

    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "染まれ…染まれ…赫く…赫く",
                             COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE2 or "与ダメージ・樹属性耐性アップ"})
    }

    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "今宵は冥月…存分に喰らい尽くそうか",
                             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE2 or "与ダメージ・魔法耐性アップ"})
    }

    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "吾が名を恐れよ、妖狐『憂月』の名を",
                             COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "クリティカル耐性・奥義増加量アップ"})
    }
end

--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 1,
            BUFF_ID = 23,
            VALUE = -100,
            DURATION = 99999,
            ICON = 188
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    event.unit:setAttackDelay(8);

    self.gameUnit:setSkin("normal")
    self:setTriggerList()
    self:setMessageBoxList()
    self:setBuffBoxList()

    self:showMessage(self.START_MESSAGE_LIST)

    self.isAwaken = false
    self.isAwakened = false
    self.countStart = false
    self.negaTimer = 1.2
    self.LIMIT = 1.2
    self.hitStop = 1

    self:initAttackWeight({FIRE_1 = 100})
    self:initSkillWeight({FIRE_1 = 100})
    self.countTime = 0
    event.unit:addSP(40)

    --テロップ用変数
    self.telopSpan = 60
    self.showMessageTimer = 0

    self.sickTimer = 30
    self.sickInterval = 30
    self.isSick = false
    self.isFreeze = false
    self.isFirst = true
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,self.hitStop)
    self:HPTriggersCheck(event.unit);
    --self:negaChange(event.deltaTime)
    self:countTimer(event.deltaTime)

    return 1
end

function class:negaChange(deltaTime)
    if not self.isNega then return end

    if self.LIMIT >= self.negaTimer then
        self.negaTimer = self.negaTimer + deltaTime
    else
        self.isNega = false
        self.gameUnit:takeGrayScale(0.99)
        self:removeGrayScale(self.gameUnit)
    end
end

--変身時の処理
function class:countTimer(deltaTime)
    if self.countStart then
        self.countTime = self.countTime + deltaTime
        if self.countTime >= 4 and self.isFirst then
            self:change()
            self.isFirst = false
        elseif self.countTime >= 7 then
            self.countStart = false
            self.gameUnit:addSP(100)
        end
    end
end

--[[
---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    event.unit:setNextAnimationName("skill1")
    event.unit:setNextAnimationEffectName("1-skill1")
    if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
    return 1
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "change" then
        self:change()
    end
    if event.spineEvent == "nega" then
        self:change()
    end
    --if event.spineEvent == "addSP" then
    --    self:addSP(event.unit);
    --end

    return 1
end
--]]
---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.isAwakened then
        event.unit:setNextAnimationEffectName("out")
    else
        event.unit:setNextAnimationEffectName("out2")
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if not self.isAwakened then
        event.unit:setNextAnimationName("back")
    else
        event.unit:setNextAnimationName("back2")
    end
    return 1
end

function class:changeAwaken()
    self.isBreak = true
    if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
    -- self.isAwaken = not self.isAwaken

end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    --[[if self.isSkilled then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
        if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
        self.isSkilled = false
        self:addBuff(self.gameUnit,self.CHANGE_BUFF_BOX)
        self.gameUnit:addSP(20)
        return 1
    end--]]

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
    self:addSP(event.unit);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.gameUnit:getBurstPoint() ~= 80 then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end

    if attackIndex == 4 then
        unit:setSetupAnimationName("idle2-cast");
    end

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    if self.gameUnit.m_breaktime <= 0 then
        unit:addSP(self.spValue);
    end
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    --self.isFreeze = false
    event.unit:setBurstState(kBurstState_active)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 4 then
        self:showMessage(self.SKILL1_MESSAGE_LIST)
    elseif event.index == 5 then
        self:showMessage(self.SKILL2_MESSAGE_LIST)
    end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self.isSkilled = true
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

function class:removeGrayScale(unit)
    for i = 0,3 do
        local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
            u:takeGrayScale(0.99)
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end


function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value

    for _,trigger in pairs(self.HP_TRIGGERS) do
        if not trigger.used and trigger.STOP_BORDER > anotherHp then
            return unit:getHP() < trigger.STOP_BORDER and 1 or self:calcDamageValue(unit,trigger.STOP_BORDER,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    local a = unit:getHP() - border
    local b = value - a
    local c = value - b
    return c
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        if event.unit:getHP() == self.HP_TRIGGERS[i].STOP_BORDER then
            return 0
        end
    end
    return 1
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
    for i,messageBox in ipairs(messageBoxList) do
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
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
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
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
        unit:resumeUnit()
    end
end

function class:removeConditionAll(unit,buffId)
    while unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil do
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
        unit:resumeUnit()
    end
end

--===================================================================================================================
--その他
--===================================================================================================================
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


---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
    return 1
end





class:publish();

return class;