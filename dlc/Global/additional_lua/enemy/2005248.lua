local class = summoner.Bootstrap.createEnemyClass({label="リアナ", version=1.3, id=2005248});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL4 = 6,
    SKILL2 = 7,
    SKILL3 = 8
}




function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isCounter = false;
    self.repulse = false;
    self.gameUnit = event.unit;
    self.timer = 0;
    event.unit:setSPGainValue(0);

    self.HPFlags = {
        [80] = {time = 20,isActive = true},
        [60] = {time = 30,isActive = true},
        [40] = {time = 40,isActive = true},
        [20] = {time = 50,isActive = true}
    }

    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end


function class:takeDamageValue(event)
    local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if self.isCounter and (skillType == 1 or skillType == 2 or skillType == 3 or skillType == 6) then
        self.isCounter = false;
        
        if self:getIsControll(event.unit) then
            self:getRepulse(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
        end
        
        return 0;
    elseif self.repulse then
        return 0;
    end
    return event.value;
end

function class:takeBreakDamageValue(event)
    local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if self.isCounter and (skillType == 1 or skillType == 2 or skillType == 3 or skillType == 6) then
        self.isCounter = false;
        
        if self:getIsControll(event.unit) then
            self:getRepulse(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
        end
        
        return 0;
    elseif self.repulse then
        return 0;
    end
    return event.value;
end

function class:takeDamage(event)
    self.repulse = false;
    return 1;
end

function class:takeBreak(event)
    --takeDamageだけで大丈夫だと思うけど一応takeBreak内でも反撃中フラグを折るようにしておく
    self.repulse = false;
    return 1;
end

function class:excuteAction(event)
    self.repulse = false;
    return 1;
end

function class:update(event)
    self.timer = self.timer + event.deltaTime;
    if self:getIsControll(event.unit) then
        --HP＆時間トリガーに引っかかった場合は最優先でそれを発動
        if self:HPTriggersCheck(event.unit) and event.unit.m_breaktime <= 0 then
            self.attackCheckFlg = true;
            event.unit:takeAttack(5);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,5); 
            event.unit:setInvincibleTime(5);
        end
    end
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end


function class:attackBranch(unit)

    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if attackIndex == "3" then
        if unit.m_breaktime <= 0 then
            self.skillCheckFlg = true;
            unit:takeSkill(4);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,4);
            return 0;
        else
            attackIndex = 4;
        end
    else
        unit:takeAttack(tonumber(attackIndex));
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
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    
    if summoner.Utility.getUnitHealthRate(unit) < 0.5 then
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

    if event.index == 4 then
        summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.cyan);
    end

    return 1
end

function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "counterStart" then
        self.isCounter = true;
    end

    if event.spineEvent == "counterEnd" then
        if self:getIsControll(event.unit) then
            self:counterEnd(event.unit)
        end
    end

    if event.spineEvent == "eventLost" then
        self:eventLost(event.unit);
    end

    if event.spineEvent == "repulseEnd" then
        self:repulseEnd(event.unit);
    end

    return 1;
end


function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end
--=====================================================================================================================================

function class:counterEnd(unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    if self:getIsControll(unit) then
        self:repulseFaild(unit);
    end
    self.isCounter = false;
end

function class:eventLost(unit)
    self:repulseFaild(unit);
    self.isCounter = false;
end

function class:getRepulse(unit)
    unit:setAnimation(0,"attack3",false);
    unit:takeAnimationEffect(0,"2-attack3",false);
    self.repulse = true;
end

function class:repulseFaild(unit)
    unit:takeAnimation(0,"counterMiss",false); --ActiveSKILLはからになる
    unit:setActiveSkill(0); --入れ直す
    unit:takeAnimationEffect(0,"counterMiss",false);
end

function class:repulseEnd(unit)
    self.repulse = false;
end


function class:HPTriggersCheck(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HPFlags) do

        if i >= hpRate and self.HPFlags[i].isActive then
            
            self.HPFlags[i].isActive = false;

            if self.timer <= self.HPFlags[i].time then
                return true;
            else
                return false;
            end
        end
    end
    return false;
end

--=====================================================================================================================================

function class:receive3(args)
    if args.arg == 0 then
        self:repulseFaild(self.gameUnit);
    else
        self:getRepulse(self.gameUnit);
    end
    return 1;
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end


class:publish();

return class;