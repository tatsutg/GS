local class = summoner.Bootstrap.createEnemyClass({label="フリード", version=1.5, id=200460038});
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

--バフカウンター配列
class.icon_Table = 
{
   165, --  1
    166, --  2
    167, --  3
    168, --  4
    174 --  5
}

class.BUFF_VALUE = 20;
class.BUFF_DURATION = 20;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.skillCheckFlg2 = false;
    self.buffCount = 0; 

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:attackElementRate(event)
    local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if skillType ~= 2 and skillType ~= 1 then
        return event.value;
    end
    local el = event.enemy:getElementType();
    if el == kElementType_Light then
        event.value = event.value + 0.2;
    end
    
    return event.value;
end

function class:attackDamageValue(event)
    event.value = event.value - event.value * (event.enemy:getTeamUnitCondition():findConditionValue(65) / 100);
    return event.value;
end

function class:update(event)
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    elseif not self.isRage then
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    else
        unit:takeAttack(tonumber(1));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self:isBuddyStillAlive(event.unit) and not self.isRage and megast.Battle:getInstance():isHost() then
        self:getRage(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
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
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if self:getIsBoss(event.unit) and event.index == 2 then
        for i=0,7 do
            local target = event.unit:getTeam():getTeamUnit(i);
            if target ~= nil and target ~= event.unit and target:getBaseID3() == 184 and megast.Battle:getInstance():isHost() then
                target:callLuaMethod("forceSkill",0.2);
            end
        end
    end
    return 1
end

function class:run (event)
    if event.spineEvent == "forceSkill" then self:forceSkill() end
    if event.spineEvent == "addBuff" then
        if (event.unit:isMyunit() or (event.unit:getisPlayer() == false and megast.Battle:getInstance():isHost())) and self.buffCount <= 4 then
            self.buffCount = self.buffCount + 1;
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.buffCount);
        end
    end
    return 1;
end

function class:addBuff(unit,buffCount)
    buff = unit:getTeamUnitCondition():addCondition(10182,22,buffCount * self.BUFF_VALUE,999999,self.icon_Table[buffCount]);
    unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:forceSkill()
    self.gameUnit:takeSkill(0);
end

function class:addSP(unit)
    if megast.Battle:getInstance():isHost() and self:getIsBoss(unit) then
        unit:addSP(self.spValue);
    end
    return 1;
end

--=====================================================================================================================================

function class:getIsBoss(unit)
    local boss = megast.Battle:getInstance():getTeam(false):getBoss();
    if boss == nil then
        return false;
    end
    return boss == unit;
end

function class:isBuddyStillAlive(unit)
    
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 184 then
            return true;
        end
    end
    return false;
    
end

function class:getRage(unit)
    self.spValue = 200;
    self.isRage = true;
    summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.red);
end

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