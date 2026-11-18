--@additionalEnemy,2004442
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="水霧ジンガルム", version=1.3, id=2004441});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50, ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    SKILL1 = 8,
    SKILL2 = 9
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP70_BUFF_LIST = {
        [1] = {
            ID = 501511,
            BUFF_ID = 17,
            VALUE = 40,
            DURATION = 99999,
            ICON = 26
        }
    }
    self.HP50_BUFF_LIST = {
        [1] = {
            ID = 501512,
            BUFF_ID = 22,
            VALUE = 100,
            DURATION = 99999,
            ICON = 11
        }
    }
    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 501513,
            BUFF_ID = 23,
            VALUE = -100,
            DURATION = 99999,
            ICON = 188,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        }
    }
    self.Rage_Timer = {
        ID = 501514,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 5,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or  "瘴気があたりを包む",
                             COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or  "反射・奥義ゲージ低下耐性、庇うキラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or  "最大HPが高いユニットへのダメージUP"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or  "ビッグフレイド：氷結以外のときダメージ無効",
                             COLOR = Color.red})
    }

    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "双頭魔獣の怒りの咆哮が響き渡る", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE2 or "与ダメージアップ"})
    }

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "双頭魔獣の咆哮が響き渡る", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "クリティカル率アップ"})
    }

    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "双頭魔獣の咆哮が響き渡る", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "クリティカル耐性・奥義増加量アップ"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            STOP_BORDER = self.gameUnit:getCalcHPMAX() * 0.7
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            STOP_BORDER = self.gameUnit:getCalcHPMAX() * 0.5
        },
        [3] = {
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
    self.hpMarkers[0] = self.gameUnit:addNumHpMarker(0)
end

function class:hp70(status)
    if status == "use3" then
        self:MultipleSummon(self.gameUnit,2004442,2)
        self.isRageMotion = true
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:setInvincibleTime(5)
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit, self.Rage_Timer)
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self:MultipleSummon(self.gameUnit,2004442,2)
        self.isRageMotion = true
        self.spValue = 30;
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:setInvincibleTime(5)
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit, self.Rage_Timer)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp30(status)
    if status == "use3" then
        self:MultipleSummon(self.gameUnit,2004442,2)
        self.isRageMotion = true
        self.spValue = 40;
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:setInvincibleTime(5)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit, self.Rage_Timer)
        self:showMessage(self.HP30_MESSAGE_LIST)
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

    self.BreakDamageCount = 0

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self.isRageMotion = false
    self.isReborn = true
    self.isFirst = true

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)
    if self.addSpFLG then
        self.isRage = true
        self.addSpFLG = false
        event.unit:addSP(100)
        --event.unit:setInvincibleTime(5)
    end

    if self.isRageMotion then
        if event.unit:getTeamUnitCondition():findConditionWithID(self.Rage_Timer.ID) == nil then
            self.isRage = true
            event.unit:addSP(100)
            self.isRageMotion = false
        end
    end

    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
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

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit)
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

    if not self.isReborn and self.isFirst then
        self.isFirst = false
        self.isRageMotion = true
        self:execAddBuff(self.gameUnit, self.Rage_Timer)
        event.unit:setInvincibleTime(7)
    end

    if not self.isReborn and event.index == 2 then
        event.unit:setInvincibleTime(7)
    end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の倍率（相手の最大 HP が 8000 を超えたら ((最大 HP − 4000) ÷ 4000) ^ 2.5）を入れる（表示専用。予測のたびに今の値で出す。古いアプリには無いので確かめてから呼ぶ）
    if event.unit.announceSkillRateBy then event.unit:announceSkillRateBy(1, 8000, 4000, 4000, 2.5) end
    return 1
    end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    if self.isRage then
        skillIndex = 2
        self.isRage = false
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
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
    if event.unit:getHP() <= 1 then
        return 0
    end
    return 1
end

----// attackDamageValue //-----------------------------------------------------------------------------
--敵の最大HPが8000より多いとき、与ダメージが ((最大HP-4000) ÷ 4000)^2.5 倍になる
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if event.enemy:getCalcHPMAX() > 8000 then
        local maxHP = event.enemy:getCalcHPMAX()
        event.value = event.value * (((maxHP - 4000) / 4000) ^ 2.5)
    end
    return event.value
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.isReborn then
        event.unit:setHP(1)
        self.isReborn = false
        event.unit:addSP(100)
        event.unit:setInvincibleTime(18)
        self.gameUnit:removeHpMarker(self.hpMarkers[0])
        return 0
    end
    return 1
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

    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
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
    if
        buffBox.FUNC ~= nil then buffBox.FUNC(buff)
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

---------------------------
function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break
            end
        end
    end
end

function class:MultipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID)
    end
end

class:publish();

return class;