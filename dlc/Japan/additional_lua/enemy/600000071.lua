local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="白亜の巨神/レイド", version=1.3, id=600000071});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
        { ATTACK4 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 100,SKILL2 = 100 },
        { SKILL3 = 100}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.TARGET_BUFF_BOX_LIST = {
        [1] = {
            ID = 501419,
            BUFF_ID = 17, -- ダメージ
            VALUE = 30,
            DURATION = 999999,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "庇うキラー・被ダメージ軽減"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ボスの奥義「絶点黙示録」発動のたびにボスの被ダメージ増加"})
    }

    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "ボスの被ダメージアップ"})
    }

    -- テロップ
    self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"

    -- レイドメッセージ
    self.RAID_MESSAGES = {
        {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red,
            DURATION = 5
        }
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



---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.TELOP_SPAN = 30
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

    self.gameUnit:addSP(60)

    self.unitIndexList = {}
    self.unitIndexList = self:searchUnitList()

    self.telopTimer = 0
    return 1
end

function class:searchUnitList()
    local lst = {}
    for i = 0,3 do
        local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if teamUnit ~= nil then
            table.insert(lst,teamUnit:getIndex())
        end
    end
    return lst
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill3End" then
        self.isSpecial = false
    end
    if event.spineEvent == "addSP" then
        self:addSP(event.unit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isSpecial then
        return 0
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeBreakeDamageValue
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.isSpecial  then
        return 0
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
    self.isSpecial = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,2)
    self:HPTriggersCheck(event.unit)
    self:setPosition(event.unit)
    self:checkUnitPosition(self.unitIndexList)

    self:telop(event.deltaTime)
    return 1
end

function class:setPosition(unit)
    unit:setZOrder(1)
    unit:setPositionX(-20);
    unit:setPositionY(-30);
    unit:getSkeleton():setPosition(0,0);
end

function class:checkUnitPosition(unitList)
    for _,v in pairs(unitList) do
        local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(v)
        if teamUnit ~= nil then
            if teamUnit:getAnimationPositionX() < 35 then
                teamUnit:setPositionX(teamUnit:getPositionX() - (teamUnit:getAnimationPositionX() - 35));
            end
        end
    end
end

function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self:checkTarget()
    return 1
end

-- 被ターゲット判定
function class:checkTarget()
    if not self.isTarget and self:getIsTarget() then
        self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
        self:showMessage(self.RAID_MESSAGES)
    end
    if self:getIsTarget() then
        BattleControl:get():showHateAll()
    else
        BattleControl:get():hideHateAll();
        self:removeBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)
    end
    self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
    return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end


---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.isSpecial = false
    if self.isSkill3 then
        self.isSkill3 = false
        self:showMessage(self.SKILL3_MESSAGE_LIST)
    end

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
    unit:addSP(self.spValue);
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.isSpecial = false
    if self.isSkill3 then
        self.isSkill3 = false
        self:showMessage(self.SKILL3_MESSAGE_LIST)
    end

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

    if event.index == 3 then
        self.isSkill3 = true
        self.isSpecial = true
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

function class:addBuffAll(unit,buffBoxList)
    for _,buffBox in ipairs(buffBoxList) do
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
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


function class:other(event)
    --ブレイク時間
    local time = event.unit.m_breaktime
end

class:publish();

return class;