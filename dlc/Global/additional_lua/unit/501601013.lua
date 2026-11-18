local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="巨神", version=1.3, id=501601013});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {}
class.ATTACK_WEIGHTS_LIST = {
    [1] = {
        ATTACK1 = 50,
        ATTACK2 = 50,
        ATTACK3 = 50
    },
    [2] = {
        ATTACK1 = 50,
        ATTACK2 = 50,
        ATTACK3 = 50
    },
    [3] = {
        ATTACK4 = 50
    }
}
--使用する奥義とその確率
class.SKILL_WEIGHTS = {}
class.SKILL_WEIGHTS_LIST = {
    [1] = {
        SKILL1 = 100,
        SKILL2 = 100
    },
    [2] = {
        SKILL1 = 100,
        SKILL2 = 100
    },
    [3] = {
        SKILL3 = 100
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
    self.attackCount = 1
    self.skillCount = 1

    self.unitIndexList = {}
    self.unitIndexList = self:searchUnitList()
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
        event.unit:setInvincibleTime(0)
    end
    if event.spineEvent == "addSP" then
        self:addSP(event.unit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:setPosition(event.unit)
    self:checkUnitPosition(self.unitIndexList)
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
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS_LIST[self.attackCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    self.attackCount = self.attackCount < 3 and self.attackCount + 1 or 1

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

    -- if event.index == 3 and not self.skillCheckFlg2 then
    --     self.skillCheckFlg2 = true;
    --     event.unit:takeSkillWithCutin(3,1);
    --     return 0;
    -- end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    if event.index == 3 then
        event.unit:setInvincibleTime(18)
    end
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS_LIST[self.skillCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    self.skillCount = self.skillCount < 3 and self.skillCount + 1 or 1

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
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

function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
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
    for i,messageBox in pairs(messageBoxList) do
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
function class:addBuff(unit,buffBoxList)
    for i,buffBox in pairs(buffBoxList) do
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
end

class:publish();

return class;
