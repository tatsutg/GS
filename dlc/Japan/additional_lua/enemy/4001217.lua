--@additionalItem,108531500
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="被験体γ－２/紋章級", version=1.3, id=4001217});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
        { ATTACK4 = 50 },
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 8,
    ATTACK5 = 5,
    ATTACK6 = 4,
    SKILL1 = 6,
    SKILL2 = 7
}

--------[[バフ]]--------
-- 掴み時に自身にかかるバフ内容
class.GLAB_SELF_BUFF_ARGS = {
    {
        ID = -11,
        BUFF_ID = 113,
        VALUE = 500,
        DURATION = 2000,
        ICON = 0
    }
}

-- 掴み時に対象にかかるバフ内容
class.GLAB_TARGET_BUFF_ARGS = {
    {
        ID = -10,
        BUFF_ID = 89,
        VALUE = 1,
        DURATION = 14,
        ICON = 0
    }
}

function class:setBuffBoxList()

    self.HP50_BUFF = {
        ID = 40012171,
        BUFF_ID = 22,   -- クリティカル
        VALUE = 50,
        DURATION = 99999,
        ICON = 11
    }
    self.HP25_BUFF = {
        ID = 40012172,
        BUFF_ID = 22,   -- クリティカル
        VALUE = 100,
        DURATION = 99999,
        ICON = 11,
        FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or  "神族・魔族キラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or  "反射耐性・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or  "ブレイクするほど被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or  "炎属性ユニットから受けるブレイク値アップ"})
    }

    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！被ダメージアップ！"})
    }

    self.BREAK_END_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE1 or "ブレイク耐性アップ"})
    }

    self.HOLD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HOLD_MESSAGE1 or "奥義ゲージが高い者をホールド"})
    }

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル率アップ"})
    }

    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "クリティカル率・攻撃速度アップ"})
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
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            trigger.hpMarker = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.isRage = true

        self.gameUnit:takeItemSkill(0)
        self.item:setCoolTimer(0)
        self.gameUnit:takeAnimation(0,"attack5",false)

        self:execAddBuff(self.gameUnit,self.HP50_BUFF)
        self:glabEnd(self.gameUnit);
    end
end

function class:hp25(status)
    if status == "use3" then
        self:showMessage(self.HP25_MESSAGE_LIST)
        self.isRage = true

        self.gameUnit:takeItemSkill(0)
        self.item:setCoolTimer(0)
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:setAttackDelay(2)

        self:execAddBuff(self.gameUnit,self.HP25_BUFF)
        self:glabEnd(self.gameUnit);
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
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)


    self.isBreak = false
    self.breakCount = 0
    self.itemId = 108531500
    self.item = event.unit:setItemSkill(0,self.itemId)
    return 1
end

function class:startWave(event)
    self:execAddBuff(event.unit,self:setBreakBuffBoxList(0))
    return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    return event.value * self:damageCorrection(self.breakCount)
end

function class:damageCorrection(count)
    local val = 1
    if     count == 0 then val = 0.07
    elseif count == 1 then val = 0.15
    elseif count == 2 then val = 0.3
    elseif count == 3 then val = 0.6
    elseif count == 4 then val = 1
    else val = val + ((count - 4) * 0.1)
    end

    return val
end

---------------------------------------------------------------------------------
-- takeBreakeDamageValue
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if event.enemy:getElementType() == kElementType_Fire then
        return event.value * 3.6
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeBreak
---------------------------------------------------------------------------------
function class:takeBreake(event)
    self:showMessage(self.BREAK_MESSAGE_LIST)
    self.isBreak = true
    self.breakCount = self.breakCount + 1
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.glabIndex ~= nil then
        local target = self:getPlayerUnit(self.glabIndex);
        if target ~= nil then
            self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
            self.glabIndex = nil
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

function class:tryGlab(unit)
    if not self:getIsHost() then
        return 1;
    end

    local targetIndex = self:checkTarget(unit);

    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:receive4(args)
    self:execGlab(self.gameUnit,args.arg);
    return 1;
end

function class:checkTarget(unit)
    local index = 0
    local sp = 0
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if sp < localUnit:getBurstPoint() then
                index = i
                sp = localUnit:getBurstPoint()
            end
        end
    end
    return index
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    self:addBuff(unit,self.GLAB_SELF_BUFF_ARGS);
    self:addBuff(target,self.GLAB_TARGET_BUFF_ARGS);

    self.glabIndex = targetIndex;
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:glabEnd(unit)
    if self.glabIndex == nil then return 1; end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then self.glabIndex = nil; return 1; end

    local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    unit:takeHitStop(0.5);
    orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    orbitHit:setTargetUnit(target);
    orbitHit:setHitType(2);
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK6);

    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:HPTriggersCheck(event.unit)
    if self.isBreak and event.unit.m_breaktime <= 0 then
        self.isBreak = false
        self:showMessage(self.BREAK_END_MESSAGE_LIST)
        self:execAddBuff(event.unit,self:setBreakBuffBoxList(self.breakCount))
    end
    self:updateGlab(event.unit)
    return 1
end

function class:setBreakBuffBoxList(count)
    local breakBuffBox = {
        ID = 40012173,
        BUFF_ID = 27, -- ブレイク耐性
        VALUE = -5 - (count * 30),
        DURATION = 99999,
        ICON = 20
    }
    return breakBuffBox
end

function class:updateGlab(unit)
    if self.glabIndex == nil then return; end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then return; end

    local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");

    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
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
    if event.index == 4 then
        self:showMessage(self.HOLD_MESSAGE_LIST)
    end
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

    if self.TRIGGERS[index].hpMarker ~= nil then
        self.gameUnit:removeHpMarker(self.TRIGGERS[index].hpMarker)
    end

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
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].hpMarker ~= nil then
        self.gameUnit:removeHpMarker(self.TRIGGERS[args.arg].hpMarker)
    end
    return 1
end


--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

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

function class:removeBuffs(unit,buffs)
    for _,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
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