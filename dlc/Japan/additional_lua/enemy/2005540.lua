local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="オージュ/闇遺跡", version=1.3, id=2005540});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 }
    },
    POWERUP = {
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50, SKILL2 = 50 },
        { SKILL2 = 50, SKILL3 = 50 },
        { SKILL8 = 50 },
        { SKILL1 = 50, SKILL3 = 50 },
        { SKILL1 = 50, SKILL2 = 50 },
        { SKILL8 = 50 },
        { SKILL2 = 50, SKILL3 = 50 },
        { SKILL1 = 50, SKILL3 = 50 },
        { SKILL8 = 50 }
    },
    POWERUP = {
        { SKILL4 = 50, SKILL5 = 50 },
        { SKILL5 = 50, SKILL6 = 50 },
        { SKILL10 = 50 },
        { SKILL4 = 50, SKILL6 = 50 },
        { SKILL4 = 50, SKILL5 = 50 },
        { SKILL10 = 50 },
        { SKILL5 = 50, SKILL6 = 50 },
        { SKILL4 = 50, SKILL6 = 50 },
        { SKILL10 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    SKILL1 = 1,
    SKILL2 = 2,
    SKILL3 = 3,
    SKILL4 = 4,
    SKILL5 = 5,
    SKILL6 = 6,
    SKILL7 = 7,
    SKILL8 = 8,
    SKILL9 = 9,
    SKILL10 = 10,
    SKILL11 = 11,
    ATTACK1 = 12,
    ATTACK4 = 13,
    ATTACK5 = 14
}

class.ANIMATION_STATE = {
    IN = {
        NORMAL = "in",
        RAGE = "in3"
    },
    BACK = {
        NORMAL = "back",
        RAGE = "back2"
    },
    DAMAGE = {
        NORMAL = "damage",
        RAGE = "damage2"
    },
    IDLE = {
        NORMAL = "idle",
        RAGE = "idle2"
    }
}
------ブレイク・ダメージ値---------
function class:setDamageBreakRateList()
    self.BreakRate = {
        [0] = 1.0,
        [1] = 0.8,
        [2] = 0.5,
        [3] = 0.3,
        [4] = 0.2,
        [5] = 0.1
    }

    self.DamageRate = {
        [0] = 0.05,
        [1] = 0.10,
        [2] = 0.3,
        [3] = 0.6,
        [4] = 1.0
    }
end


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 20055401,
            BUFF_ID = 22,   -- クリティカル率
            VALUE = 100,
            DURATION = 99999,
            ICON = 11
        }
    }
    self.Timer = {
        ID = 20055404,
        BUFF_ID = 0,   -- 無敵
        VALUE = 0,
        DURATION = 20,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "瘴気があたりを包む", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下耐性・人族キラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイクするほど被ダメージアップ"})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！被ダメージアップ！"})
    }
    self.BREAK_END_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE1 or "ブレイク耐性アップ"})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "星の怒りを知れ――", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "クリティカル率・奥義速度アップ"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 20,
            used = false,
            STOP_BORDER = self.gameUnit:getCalcHPMAX() * 0.2
        }
    }

    self.hpMarkers[30] = self.gameUnit:addNumHpMarker(0.2)
    self.hpMarkers[0] = self.gameUnit:addNumHpMarker(0)

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "RAGE"
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
--[[
    takeAttackではなく、ここでattack5のアニメーションを再生するとノータイムで再生されます。
]]
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:takeAnimationEffect(0,"1-attack5",false)
        self.gameUnit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK5)
        self.rageFirst = true
        self:execAddBuff(self.gameUnit,self.Timer)
        self.isFury = true
        self.gameUnit:removeHpMarker(self.hpMarkers[30])
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

    self.BreakCount = 0; --ブレイク回数
    self.BreakFLG = false --ブレイク後、ブレイク終了までのフラグ
    self.BreakDamageCount = 0

    self.Reborn = true --死亡時に一度復活し奥義11を発動させるフラグ

    self.hpMarkers = {}
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()
    self:setDamageBreakRateList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.gameUnit:addNumBreakBadge(6)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.BreakFLG and event.unit.m_breaktime <= 0 and self.BreakCount < 6 then
        self.BreakFLG = false
        self.BreakDamageCount = self.BreakCount
        self:showMessage(self.BREAK_END_MESSAGE_LIST)
    end
    if self.isFury and event.unit:getTeamUnitCondition():findConditionWithID(self.Timer.ID) == nil then
        self.isFury = false --無敵解除
    end
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "red" then return self:red(event.unit) end
    if event.spineEvent == "redEnd" then return self:redEnd(event.unit) end
    if event.spineEvent == "showInEffect" then return self:showInEffect(event.unit) end
    if event.spineEvent == "addRageBuff" then return self:addRageBuff(event.unit) end
    if event.spineEvent == "showRageEffect" then return self:showRageEffect(event.unit) end
    if event.spineEvent == "firestart" then return self:fireStart(event.unit) end
    if event.spineEvent == "fireloop" then return self:fireLoop(event.unit) end
    return 1;
end

function class:red(unit)
    megast.Battle:getInstance():setBackGroundColor(15,255,0,0);
    return 1;
end

function class:redEnd(unit)
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);
    return 1;
end

function class:showInEffect(unit)
    unit:takeAnimationEffect(0,"in1",false);
    return 1;
end

function class:addRageBuff(unit)
    self:initAttackWeight({POWERUP = 100})
    self:initSkillWeight({POWERUP = 100})
    self.gameUnit:addSP(100)
    return 1;
end

function class:showRageEffect(unit)
    --背景の色変える
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);
    self:fireStart(unit);
    return 1;
end

function class:fireStart(unit)
    self.fire = BattleControl:get():addAnimation("FIRE","FIRE4_00",true);
    self.fire:setPositionX(unit:getPositionX() -50);
    self.fire:setPositionY(unit:getPositionY() -20);
    self.fire:setZOrder(0);
    return 1;
end

function class:fireLoop(unit)
    self.fire:setToSetupPose();
    self.fire:setAnimation(0, "FIRE3_00",true);
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:animationSwitcher(self.ANIMATION_STATE.IDLE,event.unit);
    return 1;
end

function class:animationSwitcher(state,unit)
    unit:setNextAnimationName(state[self.stateName]);
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:animationSwitcher(self.ANIMATION_STATE.BACK,event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:animationSwitcher(self.ANIMATION_STATE.DAMAGE,event.unit);
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
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    if attackIndex == 4 then
        unit:setSetupAnimationName("idle2-cast");
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

    --if self.isFury then
    --    event.unit:setNextAnimationName("skill11")
    --    event.unit:setNextAnimationEffectName("1-skill11")
    --end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    if self.isDead then
        skillIndex = 11
    end

    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- ブレイクごとにダメージ増加
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.BreakCount < 5 then
        event.value = event.value * self.DamageRate[self.BreakCount]
    else
        local floatNum = (self.BreakCount - 4) / 10
        event.value = event.value * (1 + floatNum)
    end
    if self.isFury then
        event.value = 0
        return event.value
    end
    return event.value
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- ブレイクごとにブレイクダメージ低下(5回まで)
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    event.value = event.value * self.BreakRate[self.BreakDamageCount]
    event.value = self:adjustHpFlg(event.unit,event.value)
    if self.isFury then
        event.value = 0
        return event.value
    end
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
-- 条件 : ブレイク時。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:takeBreake(event)
    self.BreakFLG = true
    self:showMessage(self.BREAK_MESSAGE_LIST)
    self.BreakCount = self.BreakCount + 1
    self.gameUnit:removeNumBreakBadge()
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

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true

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
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.Reborn then
        self.Reborn = false
        event.unit:setHP(1)
        event.unit:setInvincibleTime(28)
        --event.unit:takeAnimation(0,"skill11",false)
        --event.unit:takeAnimationEffect(0,"1-skill11",false)
        self.isDead = true
        event.unit:addSP(100)
        self.gameUnit:removeHpMarker(self.hpMarkers[0])
        return 0
    end
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

class:publish();

return class;