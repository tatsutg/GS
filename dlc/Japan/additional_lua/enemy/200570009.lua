--@additionalEnemy,200570013
local class = summoner.Bootstrap.createEnemyClass({label="ロスト", version=1.3, id=200570009});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    SKILL1 = 1,
    SKILL2 = 2,
    SKILL3 = 3
}

class.BUFF_ARGS = {
    ID = 101991,
    EFID = 13,
    VALUE = 30,
    DURATION = 999999,
    ICON = 3
}


class.SUMMON_ENEMY = 200570013;
class.SUMMON_ENEMY_POSITION = 4;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.buffcount = 0;
    self.isBreak = false;
    self.breakGaseTimer = 0;

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    return 1;
end

function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.yellow);
    return 1;
end

function class:update(event)
    if self.isBreak then
        self.breakGaseTimer = self.breakGaseTimer + event.deltaTime;
        if self.breakGaseTimer < 0.1 then
            return 1;
        end
        self.breakGaseTimer = 0;
        if event.unit.m_breaktime <= 0 then
            local buff =  event.unit:getTeamUnitCondition():findConditionWithID(200570009);
            if buff ~= nil then
                event.unit:getTeamUnitCondition():removeCondition(buff);
            end
            self.isBreak = false;
        end
    end
    return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
     if summoner.Utility.getUnitHealthRate(unit) < 0.5 and not self.isRage then
        self:getRage(unit);
        self:addUnit(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
    end 
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)

    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    -- self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        skillIndex = 3;
    end
    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    if self.buffcount < 5 and megast.Battle:getInstance():isHost() and event.index ~= 1 then
        self.buffcount = self.buffcount + 1;
        self:addBuff(event.unit,self.buffcount);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.buffcount);
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:takeBreake(event)
    event.unit:getTeamUnitCondition():addCondition(200570009,64,-100,12,46);
    self.isBreak = true;
    return 1;
end

function class:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if not(enemy == nil )then
            enemy:setParameter("lastLeave","TRUE"); 
            local cond = enemy:getTeamUnitCondition():findConditionWithID(2001);
            if cond ~= nil then
                enemy:getTeamUnitCondition():removeCondition(cond);
            end
            enemy:setHP(0);
        end
    end
    return 1;
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:getRage(unit)
    self.isRage = true;
    -- summoner.Utility.messageByEnemy(self.TEXT.mess4,5,summoner.Color.green);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.yellow);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess6,5,summoner.Color.red);
end


function class:addUnit(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    if unit:getTeam():getTeamUnit(self.SUMMON_ENEMY_POSITION) == nil then
        local enemy = unit:getTeam():addUnit(self.SUMMON_ENEMY_POSITION,self.SUMMON_ENEMY);
    end
end

function class:addBuff(unit,buffcount)
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ARGS.ID,self.BUFF_ARGS.EFID,self.BUFF_ARGS.VALUE * buffcount,self.BUFF_ARGS.DURATION,self.BUFF_ARGS.ICON);
end

--=====================================================================================================================================

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;