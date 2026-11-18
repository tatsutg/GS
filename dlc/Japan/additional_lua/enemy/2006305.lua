--@additionalEnemy,2006308,2006306,2006307
local class = summoner.Bootstrap.createEnemyClass({label="ぴえんつ", version=1.3, id=2006305});
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
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}


class.SUMMON_ENEMYS = {
    [0] = {
        ID = 2006308,
        BUFFID = 102231,
        BUFFEF = 28,
        BUFFVALUE = 15,
        ICON = 7
    },
    [1] = {
        ID = 2006306,
        BUFFID = 102232,
        BUFFEF = 13,
        BUFFVALUE = 30,
        ICON = 3
    },
    [2] = {
        ID = 2006307,
        BUFFID = 102233,
        BUFFEF = 15,
        BUFFVALUE = 30,
        ICON = 5
    }
}


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.buffCounts = {[0] = 0,[1] = 0,[2] = 0}
    self.firstSummon = true;
    self.isBarrier = false;
    self.buddyCheckTimer = 0;


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess3,5,summoner.Color.red);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.magenta);
    return 1;
end

function class:takeDamageValue(event)
    return self.isBarrier and 1 or event.value;
end


function class:update(event)
    self.buddyCheckTimer = self.buddyCheckTimer + event.deltaTime;
    if self.buddyCheckTimer >= 0.2 then
        self.buddyCheckTimer = 0;
        self:checkBarrierShift(event.unit);
    end
    return 1;
end

function class:excuteAction(event)
    --怒り移行の分岐　HPが５０％を切ったら
    -- if not self.isRage and megast.Battle:getInstance():isHost() and summoner.Utility.getUnitHealthRate(event.unit) < 0.5 then
    --     self:getRage(event.unit);
    --     megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
    -- end 
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    
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
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        skillIndex = "3";
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
    self:checkArts(event.unit,event.index);
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:dead(event)
    self:creanUpEnemy(event.unit);
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:getRage(unit)
    self.isRage = true;
end



--=====================================================================================================================================

function class:checkArts(unit,index)
    if index >= 2 then
        self:summon(unit);
    end
end

function class:summon(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local rand = LuaUtilities.rand(2) + 1;
            if self.firstSummon then
                rand = 0;
                self.firstSummon = false;
            end
            local enemyID = self.SUMMON_ENEMYS[rand].ID;
            self:addBuff(unit,rand);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,rand);
            unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            cnt = cnt + 1; 
            if cnt >= 1 then
                break;
            end
        end
    end
end

function class:addBuff(unit,index)
    local args = self.SUMMON_ENEMYS[index];
    self.buffCounts[index] = self.buffCounts[index] + 1;
    unit:getTeamUnitCondition():addCondition(args.BUFFID,args.BUFFEF,args.BUFFVALUE * self.buffCounts[index],99999,args.ICON);
end

--=====================================================================================================================================

function class:checkBarrierShift(unit)
    local buddyFlag = self:isBuddyStillAlive(unit);
    if self.isBarrier ~= buddyFlag then
        self:showBarrierMessages(buddyFlag);
    end
    self.isBarrier = buddyFlag;
end


function class:showBarrierMessages(isBarrier)
    if isBarrier then
        summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
    else
        summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.yellow);
    end
end


function class:isBuddyStillAlive(unit)
    
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit then
            return true;
        end
    end
    return false;
    
end

function class:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
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