local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ベルギラス", version=1.3, id=2028854});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK3 = 50},
        { ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL1 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 5,
    SKILL3 = 7
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP70_BUFF_LIST = {
        [1] = {
            ID = 20274541,
            BUFF_ID = 112,   -- 状態異常耐性
            VALUE = 20,
            DURATION = 99999,
            ICON = 67
        }
    }

    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 20274543,
            BUFF_ID = 17,   -- 与ダメ
            VALUE = 30,
            DURATION = 99999,
            ICON = 26
        }
    }

    self.STUN_BUFF = {
        ID = 20274545,
        BUFF_ID = 89, -- 気絶
        VALUE = 100,
        DURATION = 2,
        ICON = 79
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.green,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "状態異常時以外ダメージ無効"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "状態異常の数に応じて被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "樹・水・闇属性キラー"})
    }

    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "ボスの状態異常耐性アップ"})
    }

    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "ボスの与ダメージアップ"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList(unit)
    self.TRIGGERS = {
        {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            STOP_BORDER = unit:getCalcHPMAX() * 0.7
        },
        {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            STOP_BORDER = unit:getCalcHPMAX() * 0.5
        },
        {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            STOP_BORDER = unit:getCalcHPMAX() * 0.3
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

function class:hp70(status)
    if status == "use3" then
        self:showMessage(self.HP70_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_LIST[1])
    end
end

function class:hp50(status)
    if status == "use3" then
        self.isRage = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(8)
    end
end

function class:hp30(status)
    if status == "use3" then
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
    end
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

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList(event.unit)
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    event.unit:setSkin("normal");
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:HPTriggersCheck(event.unit)
    return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustValue(event.unit,event.value)

    return self:adjustHpFlg(event.unit,event.value)
end

function class:adjustHpFlg(unit,value)
    --local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    local anotherHp = unit:getHP() - value

    for _,trigger in pairs(self.HP_TRIGGERS) do
        if not trigger.used and trigger.STOP_BORDER > anotherHp then
            return unit:getHP() < trigger.STOP_BORDER and 0 or self:calcDamageValue(unit,trigger.STOP_BORDER,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    unit:setHP(border - 1)
    --local a = unit:getHP() - border
    --local b = value - a
    --local c = value - b
    return 1
end

class.CHECK_LIST = {
    [89] = 1,
    [90] = 1,
    [91] = 1,
    [92] = 1,
    [93] = 1,
    [94] = 1,
    [95] = 1,
    [96] = 1,
    [97] = 1,
    [129] = 1,
    [131] = 1,
    [135] = 1
}

function class:adjustValue(unit,value)
    return value * self:checkCondition(unit)
end

function class:checkCondition(unit)
    local count = 0
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil and self.CHECK_LIST[cond:getConditionTypeAsInt()] ~= nil then
            count = count < 1 and count + 0.2 or 1
        end
    end

    return count == 0 and 0 or 1 + count
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)

    return self:checkCondition(event.unit) == 0 and event.value * 1.5 or event.value
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
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    if not self.isSpecial then
        unit:addSP(self.spValue);
    end
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.isSpecial = false
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
    if event.index == 2 and not self.isRage and megast.Battle:getInstance():isHost() then self:checkPartyHP() end
    if self.isRage then
        self.isRage = false
        event.unit:setActiveSkill(7)
    else
        self:skillActiveSkillSetter(event.unit,event.index);
    end
    self:initAttackWeight()
    return 1
end

function class:checkPartyHP()
    local tbl = {}

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            table.insert(tbl,{HP = myTeamUnit:getHP(),UNIT = myTeamUnit})
        end
    end
    table.sort(tbl, function(a,b) return a.HP>=b.HP end)
    local count = 0
    for _,v in ipairs(tbl) do
        count = count +1
        self:execAddBuff(v.UNIT,self.STUN_BUFF)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,v.UNIT:getIndex());
        if count == 2 then return end
    end
end

function class:receive5(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local myTeamUnit = myTeam:getTeamUnit(args.arg)
    self:execAddBuff(myTeamUnit,self.STUN_BUFF)
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 2
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
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
function class:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeAttackFromHost(unit,index)
    self.isSpecial = false
    self.fromHost = true;
    unit:takeAttack(index);
end

function class:takeSkillFromHost(unit,index)
    self.isSpecial = false
    self.fromHost = true;
    unit:takeSkill(index);
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if unit == nil then return end

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

class:publish();

return class;