local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="SKコラボ_妖狐「憂月」", version=1.8, id=2031554})
class:inheritFromUnit("unitBossBase");

--[[
ATTACK1,5 火の玉突進
ATTACK2,6 噴火
ATTACK3,7 剣撃
]]

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    FIRE_1 = {
        { ATTACK3 = 50},
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50},
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50}
    },
    DARK_1 ={
        { ATTACK7 = 50},
        { ATTACK5 = 50, ATTACK6 = 50, ATTACK7 = 50},
        { ATTACK5 = 50, ATTACK6 = 50, ATTACK7 = 50}
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
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK5 = 4,
    ATTACK6 = 5,
    ATTACK7 = 6,
    SKILL1 = 7,
    SKILL4 = 8,
    SKILL5 = 9
}

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
            action = function (status) self:hp20(status) end,
            HP = 20,
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
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit,self.CONDITION_BUFF_LIST[1])
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.gameUnit:takeAnimation(0,"skill1",false)
        self.gameUnit:takeAnimationEffect(0,"1-skill1",false)
        self.gameUnit:setActiveSkill(7)
        self.countStart = true
        self:removeBadCondition(self.gameUnit)
        self.afterSkillFLG = true
        self.afterHp50FLG = true
    end
end
function class:hp20(status)
    if status == "use3" then
        self.spValue = 40;
        self:execAddBuff(self.gameUnit,self.HP20_BUFF_LIST[1])
        self:showMessage(self.HP20_MESSAGE_LIST)
        self.gameUnit:addSP(100)
        self:removeBadCondition(self.gameUnit)
        self:teamAddBuff(self.STAN_BUFF_LIST[1],true)
    end
end

--全体を対象にバフ付与
function class:teamAddBuff(buffBox,isPlayer)
    local myTeam = megast.Battle:getInstance():getTeam(isPlayer);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:removeBadCondition(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for typeId = 89,97 do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                end
            end
        end
    end
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or  "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or  "魔族からのダメージを軽減"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or  "暗闇時、攻撃力ダウン"})
    }

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "我が名を讃えよ、妖狐、憂月の名を",
                             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "状態異常を回復＆命中率アップ"})
    }

    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "汝らに破滅を贈ろう",
                             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "状態異常を回復"}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE3 or "与ダメージ・奥義ゲージ上昇量アップ"})
    }

    self.BLIND_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BLIND_MESSAGE1 or "暗闇状態になって攻撃力ダウン！",
                             COLOR = Color.red})
    }
end

--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP50_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 32,
            VALUE = 80,
            DURATION = 99999,
            ICON = 14
        }
    }
    self.HP20_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = 50,
            DURATION = 99999,
            ICON = 26
        }
    }
    self.BLIND_BUFF_LIST = {
        [1] = {
            ID = 2031554,
            BUFF_ID = 13,
            VALUE = -100,
            DURATION = 99999,
            ICON = 4
        },
        [2] = {
            ID = 2031554,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.CONDITION_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 113,
            VALUE = 99999,
            DURATION = 7,
            ICON = 67
        }
    }
    self.STAN_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 30;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    event.unit:setAttackDelay(3);

    self.gameUnit:setSkin("normal")
    self:setTriggerList()
    self:setMessageBoxList()
    self:setBuffBoxList()

    self:showMessage(self.START_MESSAGE_LIST)

    self.isAwaken = false
    self.isAwakened = false
    self.countStart = false
    self.negaTimer = 1.2

    self.hitStop = 1

    self:initAttackWeight({FIRE_1 = 100})
    self:initSkillWeight({FIRE_1 = 100})
    self.countTime = 0
    event.unit:addSP(40)

    self.isFirst = true
    self.BlindFLG = false
    self.afterSkillFLG = true
    self.afterHp50FLG = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,self.hitStop)
    self:HPTriggersCheck(event.unit);
    self:countTimer(event.deltaTime)
    self:checkBlind(event.unit)
    return 1
end

function class:checkBlind(unit)
    local cond93 = unit:getTeamUnitCondition():findConditionWithType(93);
    if cond93 ~= nil then
        if not self.BlindFLG then
            self:execAddBuff(unit,self.BLIND_BUFF_LIST[1])
            self:showMessage(self.BLIND_MESSAGE_LIST)
            self.BlindFLG = true
        end
    else
        if self.BlindFLG then
            self:execAddBuff(unit,self.BLIND_BUFF_LIST[2])
            self.BlindFLG = false
        end
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
            self.gameUnit:setBurstPoint(80)
        end
    end
end

function class:change()
    self:awaken()
    self.isNega = true
    self.negaTimer = 0
--[[
    for i = 0,3 do
        local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
            u:takeGrayScale(0.01)
        end
    end
]]--
end

function class:awaken()
    self.isAwakened = true
    self.gameUnit:setSkin("rage")
    self:initAttackWeight({DARK_1 = 100})
    self:initSkillWeight({DARK_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,241,35,177);
    megast.Battle:getInstance():setBossCounterElement(5);
    self.gameUnit:setElementType(5);
end

function class:normal()
    self.isAwakened = false
    self.gameUnit:setSkin("normal")
    self:initAttackWeight({FIRE_1 = 100})
    self:initSkillWeight({FIRE_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,255,255,255);
    megast.Battle:getInstance():setBossCounterElement(1);
    self.gameUnit:setElementType(1);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

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
    if self.afterSkillFLG then
        self.afterSkillFLG = false
    else
        self:addSP(event.unit);
    end
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    elseif self.afterHp50FLG then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
        self.afterHp50FLG = false
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
    event.unit:setBurstState(kBurstState_active)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self.afterSkillFLG = true
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
    if self.countStart then
        event.value = event.value * 0.1
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
    return unit:getHP() - border + 1
end


----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    if self.countStart then
        return 0
    end
    return 1
end

----// takeDamage //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.countStart then
        return 0
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
    self.TRIGGERS[args.arg].used = true
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
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