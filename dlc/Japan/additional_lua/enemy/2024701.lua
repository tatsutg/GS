--@additionalEnemy,2024702
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹怪鳥", version=1.3, id=2024701});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 100 },
        { ATTACK4 = 50 , ATTACK5 = 50 },
        { ATTACK5 = 70 , ATTACK7 = 30 },
        { ATTACK4 = 50 , ATTACK5 = 50 },
        { ATTACK7 = 100 },
        { ATTACK5 = 100 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 },
        { SKILL1 = 100 },
        { SKILL3 = 100 },
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 1,
    ATTACK3 = 1,
    ATTACK4 = 1,
    ATTACK5 = 2,
    ATTACK6 = 3,
    ATTACK7 = 3,
    SKILL1 = 4,
    SKILL2 = 5,
    SKILL3 = 6,
    SKILL4 = 1
}

class.ANIMATION_LIST = {
    "idle",
    "idle2",
    "damage",
    "damage2"
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 40075,
            BUFF_ID = 31,      --回避率アップ
            VALUE = 100,       --効果量
            DURATION = 9999999,
            ICON = 16
        },
        [2] = {
            ID = 501081,
            BUFF_ID = 27,
            VALUE = 30,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.DEF_BUFF_BOX_LIST = {
        [1] = {
            ID = 40076,
            BUFF_ID = 13,      --攻撃力アップ
            VALUE = 100,       --効果量
            DURATION = 9999999,
            ICON = 3
        },
        [2] = {
            ID = 40077,
            BUFF_ID = 17,      --与ダメアップ
            VALUE = 100,       --効果量
            DURATION = 9999999,
            ICON = 26
        }
    }

    self.BREAK_BUFF_BOX_LIST = {
        [1] = {
            ID = -1,
            BUFF_ID = 61,      --炎耐性
            VALUE = -40,       --効果量
            DURATION = 9999999,
            ICON = 43
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "水属性キラー",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "炎属性弱点",
            COLOR = Color.green
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイクするたびに炎属性耐性低下",
            COLOR = Color.green
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "メル＝ヴァーラ：魔法無効"
        })
    }
    self.BUFF_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.BUFF_MESSAGE or "暴風状態",
            COLOR = Color.green
        })
    }
    self.REMOVE_BUFF_MESSAGE_LIST = {
        --[1] = self:setMessageInfo({
        --    MESSAGE = self.TEXT.REMOVE_BUFF_MESSAGE1 or "暴風状態解除",
        --    COLOR = Color.green
        --}),
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.REMOVE_BUFF_MESSAGE1 or "炎属性耐性低下",
            COLOR = Color.green
        })
    }
    self.SKILL3_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "暴風は無慈悲な刃となり命を切り刻む",
            COLOR = Color.red
        })
    }

end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:switchWind(status)
    if not self.isChoice then return end

    if self.windUnit == nil then
        self.windUnit = self.gameUnit:addOrbitSystem("wind_roop")
        self.windUnit:setAnimation(0,"wind_roop",true)
        self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
        self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
        self.windUnit:setZOrder(9998);
        --self:showMessage(self.BUFF_MESSAGE_LIST)
    end

    if status == "showWindAura" then
        if self.isBreak then
            return
        end

        --if self.gameUnit:getTeamUnitCondition():findConditionWithType(self.BUFF_BOX_LIST[1].BUFF_ID) == nil then
            --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
            --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        --end
        self.windUnit:setAnimation(0,"wind_roop",true)
    end

    if status == "hideWindAura" then
        self.windUnit:setAnimation(0,"enpty",true)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.MEL_SUMMON_ID = 2024702
class.MEL_FIND_ID = 24
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    event.unit:setAttackDelay(4.2)

    self.isRage = false
    self.isFury = false
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self.isBreak = false
    self.isFlying = true
    self.windUnit = nil
    self.timer = 0
    self.timeLimit = 300
    self.breakTime = -1

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self.gameUnit:addSP(60)
    self:execAddBuff(self.gameUnit,self.DEF_BUFF_BOX_LIST[1])
    self:execAddBuff(self.gameUnit,self.DEF_BUFF_BOX_LIST[2])
    self:showMessage(self.START_MESSAGE_LIST)

    return 1
end

-- ホストでアニメーションを設定してゲストに流す
function class:setBirdAnimation(index)
    if megast.Battle:getInstance():isHost() then
        self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[index])
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,index);
    end
end

function class:receive4(args)
    self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[args.arg])
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100, 1)
    self:HPTriggersCheck(event.unit,event.unit)
    self:checkMel(event.unit,event.deltaTime)
    self:setWindPosition()
    self:setTimeUp(event.deltaTime)
    if self.isBreak and self.gameUnit.m_breaktime <= 0 then
        self.breakTime = -1
        self.isBreak = false
        self.isFlying = true
    end
    return 1
end


-- 300秒経ったらタイムアップ
function class:setTimeUp(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(10);
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self.isBattleEnd = true;
    end
end

function class:checkMel(unit,deltaTime)
    self.timer = self.timer + deltaTime
    if self:isOver(self.timer,self:countUnit(unit,self.MEL_FIND_ID)) then
        self.timer = 0
        self:summon(unit,self.MEL_SUMMON_ID)
    end
end

function class:isOver(time,melCount)
    local cnt = 5 - melCount
    if time * (cnt^2) > 120 then
        return true
    end
    return false
end

function class:countUnit(unit,unitID)
    local count = 0
    for i = 0, 6 do
        local localUnit = unit:getTeam():getTeamUnit(i)
        if localUnit ~= nil and localUnit:getBaseID3() == unitID then
            count = count + 1
        end
    end
    return count > 5 and 5 or count
end

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

function class:setWindPosition()
    if self.windUnit ~= nil then
        self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
        self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
    end
end
---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.isFlying then
        self:setBirdAnimation(1)
    else
        self:setBirdAnimation(2)
    end
    return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.isFlying then
        self:setBirdAnimation(3)
    else
        self:setBirdAnimation(4)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if "takeOFfEnd" == event.spineEvent then
        self.isFlying = true
    end
    if "hideWindAura" == event.spineEvent or "showWindAura" == event.spineEvent then
        self:switchWind(event.spineEvent)
    end
    if "addSP" == event.spineEvent then
        event.unit:addSP(self.spValue);
    end
    if "choiceEnemy" == event.spineEvent then
        self.isChoice = true
        self:sliceHP()
        self:switchWind("showWindAura")
    end
    return 1
end

function class:sliceHP()
    if not megast.Battle:getInstance():isHost() then return end

    local units = {}
    for i = 0,3 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil and uni:getHP() > uni:getCalcHPMAX()/10 then
            table.insert(units,uni);
        end
    end

    if table.maxn(units) >= 1 then
        local rand = LuaUtilities.rand(table.maxn(units)) + 1;--luaのテーブルは１からスタート
        local tgt = units[rand];
        tgt:setHP(tgt:getCalcHPMAX()/10)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,tgt:getIndex());
    end
end

function class:receive5(args)
    local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg)
    if uni ~= nil then
        uni:setHP(uni:getCalcHPMAX()/10)
    end
    return 1
end

---------------------------------------------------------------------------------
-- break
---------------------------------------------------------------------------------
function class:takeBreake(event)
    if event.unit.m_breaktime == 0 and self.breakTime < 0 then
        self.breakTime = 0
        self.isFlying = false
        self.isBreak = true
        --self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[1].ID)
        --self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[2].ID)
        --self:switchWind("hideWindAura")

        self:execAddBuff(self.gameUnit,self.BREAK_BUFF_BOX_LIST[1])
        self:showMessage(self.REMOVE_BUFF_MESSAGE_LIST)
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.isBattleEnd then
        return 9999999;
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    for i = 0,7 do
        local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
        if teamUnit ~= nil then
            teamUnit:setHP(0)
        end
    end
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
    if event.index == 7 then
        self:showMessage(self.SKILL3_MESSAGE_LIST)
    end
    return 1
end

function class:attackReroll(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    self:weightController(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
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
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if not self.isFlying then
        self.isFlying = true
        unit:takeSkill(4)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,4);
        return 0
    else
        self:weightController(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
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

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end
end

--===================================================================================================================
--その他
--===================================================================================================================
function class:weightController(SET_LIST,stateBox)
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

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
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