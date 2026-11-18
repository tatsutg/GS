local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇遺跡トニトゥルス", version=1.3, id=2005541});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50,ATTACK5 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50,SKILL2 = 50,SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 2005541,
            BUFF_ID = 14,
            VALUE = 30000,
            DURATION = 99999,
            ICON = 5
        },
        [2] = {
            ID = 2005541,
            BUFF_ID = 31,
            VALUE = 95,
            DURATION = 99999,
            ICON = 16
        },
        [3] = {
            ID = 0,
            BUFF_ID = 14,
            VALUE = 60000,
            DURATION = 99999,
            ICON = 5
        },
        [4] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = 50,
            DURATION = 99999,
            ICON = 26
        },
        [5] = {
            ID = 2005541,
            BUFF_ID = 31,
            VALUE = 170,
            DURATION = 99999,
            ICON = 16
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカルダメージ無効"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "防御力アップ"})
    }
    self.DEFENCE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEFENCE_MESSAGE1 or "回避率アップ解除"}),
        self:setMessageInfo({MESSAGE = self.TEXT.DEFENCE_MESSAGE2 or "防御力アップ"})
    }
    self.AVOID_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.AVOID_MESSAGE1 or "防御力アップ解除"}),
        self:setMessageInfo({MESSAGE = self.TEXT.AVOID_MESSAGE2 or "回避率アップ"})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "防御力アップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.AVOID_MESSAGE2 or "回避率アップ"})
    }
    self.WIND_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.WIND_MESSAGE1 or "暴風状態：20秒ごとにダメージUP"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hpAvoid(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hpDefence(status) end,
            HP = 60,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hpAvoid(status) end,
            HP = 40,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        },
        [5] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
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

function class:hpDefence(status)
    if status == "use3" then
        self.gameUnit:setInvincibleTime(2)
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1])
        self:showMessage(self.DEFENCE_MESSAGE_LIST)
    end
end

function class:hpAvoid(status)
    if status == "use3" then
        self.gameUnit:setInvincibleTime(2)
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2])
        self:showMessage(self.AVOID_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.gameUnit:setInvincibleTime(2)
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3])
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[5])
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.isRage = true
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
    self.afterSkillFLG = false;

    self.BreakDamageCount = 0

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

    self.stateName = "NORMAL"
    self.gameUnit:setInvincibleTime(2)
    self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1])
    self.windTime = 0
    self.isWind = false
    self.hideWind = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(2,1)
    self:setWindPosition(event.deltaTime)
    return 1
end

function class:setWindPosition(deltaTime)
    if self.windUnit ~= nil then
        self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
        self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
        self.windTime = self.windTime + deltaTime
        if self.windTime > 20 then
            self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[4])
            self.windTime = self.windTime - 20
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "showWindAura" then self:wind() end
    return 1;
end

function class:wind()
    self:showWind()

    if self.isWind then
        self.isWind = false
        self.windUnit = self.gameUnit:addOrbitSystem("wind_roop")
        self.windUnit:setAnimation(0,"wind_roop",true)
        self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
        self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
        self.windUnit:setZOrder(9998);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[4])
        self:showMessage(self.WIND_MESSAGE_LIST)
    end
end

function class:hide_Wind()
    if self.windUnit ~= nil then
        self.windUnit:setAnimation(0,"enpty",true)
        self.hideWind = true
    end
end

function class:showWind()
    if self.windUnit ~= nil then
        if self.hideWind then
            self.windUnit:setAnimation(0,"wind_roop",true)
            self.hideWind = false
        end
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

    self.fromHost = false;

    if self.isWind then
        self:wind()
    end
    self:showWind()
    if event.index == 6 then
        self.isWind = true
    end

    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    --[[--下記コード使用で行動前に奥義ゲージが上がるユニットでも行動パターンを崩さず奥義を撃てる(必要に応じて改造)
    if self.gameUnit:getBurstPoint() ~= 80 then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    ]]--
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    if self.isRage then
        attackIndex = 6
        self.isRage = false
    end

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
        self:hide_Wind()
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
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
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value,trigger)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value,trigger)
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
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() == stopBorder then
            return 0
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
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
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

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
    for i,value in ipairs({89,91,96}) do
        local condition = unit:getTeamUnitCondition():findConditionWithType(value)
        if condition ~= nil then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
    end
end

class:publish();

return class;