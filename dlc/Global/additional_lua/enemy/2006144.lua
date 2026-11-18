local class = summoner.Bootstrap.createEnemyClass({label="すらい", version=1.3, id=2006144});
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

--バフカウンター配列
class.icon_Table = 
{
   165, --  1
    166, --  2
    167, --  3
    168, --  4
    174 --  5
}

class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isLunatic = false;
    self.isRage = false;
    self.firstArts = true;


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
    summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    if self.isLunatic then
        event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　100%軽減
        if event.unit.m_breaktime <= 0 then
            event.unit:setBurstPoint(100);
        else
            event.unit:setBurstPoint(0);
        end

    end
    return 1;
end

function class:excuteAction(event)
    --怒り移行の分岐　HPが５０％を切ったら
    if not self.isRage and megast.Battle:getInstance():isHost() and summoner.Utility.getUnitHealthRate(event.unit) < 0.5 then
        self:getRage(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
    end 
    return 1;
end

function class:takeDamageValue(event)
    if not self.isLunatic and event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical and megast.Battle:getInstance():isHost() then
        self:getLunatic();
        self:getRage(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return event.value;
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

    local lunaticCutin = not self.isLunatic or self.firstArts; 

    if event.index == 3 and not self.skillCheckFlg2 and lunaticCutin then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    if self.isLunatic and self.firstArts then
        self.firstArts = false;
        summoner.Utility.messageByEnemy(self.TEXT.mess5,5,summoner.Color.cyan);
    end
    if event.index == 3 and self.isLunatic then
        event.unit:setNextAnimationName("skill4");
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:getRage(unit)
    self.isRage = true;
end

function class:getLunatic()
    summoner.Utility.messageByEnemy(self.TEXT.mess3,5,summoner.Color.cyan);
    summoner.Utility.messageByEnemy(self.TEXT.mess4,7,summoner.Color.red);
    self.isLunatic = true;
end


--=====================================================================================================================================

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:getLunatic();
    self:getRage(self.gameUnit);
    return 1;
end

class:publish();

return class;