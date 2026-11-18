local class = summoner.Bootstrap.createEnemyClass({label="ラプレ", version=1.3, id=200460032});
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

class.RECAST = 5;
class.EVOLUTION_LANK = 2;
class.BUFF_VALUE = 50;
class.SKILL_RATE = 400;

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.skillCheckFlg2 = false;
    self.orbit = nil;
    self.bitRank = 0;
    self.isFollow = false;
    self.coolTime = 0;

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.cyan);
    return 1;
end

function class:update(event)
    self.coolTime = self.coolTime + event.deltaTime;
    if self.orbit ~= nil and self.isFollow then
        self.orbit:setPosition(event.unit:getAnimationPositionX(),event.unit:getAnimationPositionY()-60);
        self.orbit:getSkeleton():setPosition(0,0);
    end
    return 1;
end

function class:takeDamageValue(event)
    if event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
        return 1;
    end
    return event.value;
end

--===========================================================================================================================

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
    -- if not self:isBuddyStillAlive(event.unit) and not self.isRage and megast.Battle:getInstance():isHost() then
    --     self:getRage(event.unit);
    --     megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    -- end
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if self.orbit ~= nil and self.coolTime > self.RECAST then
        self.coolTime = 0;
        self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."a"..self.bitRank,true);
    end

    self.fromHost = false;
    -- self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

--===========================================================================================================================

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
    -- self:skillActiveSkillSetter(event.unit,event.index);
    if self:getIsBoss(event.unit)  and event.index == 2 then
        for i=0,7 do
            local target = event.unit:getTeam():getTeamUnit(i);
            if target ~= nil and target ~= event.unit and target:getBaseID3() == 185 and megast.Battle:getInstance():isHost() then
                target:callLuaMethod("forceSkill",0.2);
            end
        end
    end
    return 1
end


--===========================================================================================================================

function class:run (event)
    if event.spineEvent == "forceSkill" then self:forceSkill() end
    if event.spineEvent == "addBit" then self:addBit(event.unit) end
    if event.spineEvent == "takeBitSkill" then self:takeBitSkill(event.unit) end
    if event.spineEvent == "takeBitSkill2" then self:takeBitSkill2(event.unit) end
    if event.spineEvent == "attackEnd" then self:attackEnd(event.unit) end
    if event.spineEvent == "skillEnd" then self:skillEnd(event.unit) end
    if event.spineEvent == "inEnd" then self:inEnd(event.unit) end
    if event.spineEvent == "outEnd" then self:outEnd(event.unit) end
    return 1;
end

function class:forceSkill()
    self.gameUnit:takeSkill(0);
end

--===========================================================================================================================

function class:addSP(unit)
    if megast.Battle:getInstance():isHost() and self:getIsBoss(unit) then
        unit:addSP(self.spValue);
    end
    return 1;
end

--===========================================================================================================================
--ビット関係のメソッド

function class:addBit(unit)
    if megast.Battle:getInstance():isHost() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.bitRank);
        self:innerAddBit(unit,self.bitRank); 
    end
end

--ビットをしまってから再展開するという動きになるためこのメソッドでは仕舞ってカウンターを上げてバフをかけるだけ
--次のINアニメーションを再生する処理はoutアニメーション終了時にSpineから呼ばれるoutEndに任せている
function class:innerAddBit(unit,rank)
    self.bitRank = rank;

    if self.orbit == nil then
        self.isFollow = true;
        local bit = self.gameUnit:addOrbitSystem(self.EVOLUTION_LANK.."in1",0)
        bit:setHitCountMax(9999999);
         self.orbit = bit;
        
        if self.isRage then
            bit:takeAnimation(0,self.EVOLUTION_LANK.."in4",true);
            self.bitRank = 4;
        else
            bit:takeAnimation(0,self.EVOLUTION_LANK.."in1",true);
            self.bitRank = 1;
        end
        
    else
        if self.isRage and self.bitRank < 4 then
            self.bitRank = 3;
        end
        if self.bitRank >= 4 then
            self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."a"..self.bitRank,true);
            return;
        end
        self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."out"..self.bitRank,true);
        self.bitRank = self.bitRank + 1;
    end
    -- local buff = unit:getTeamUnitCondition():addCondition(1,17,self.bitRank * self.BUFF_VALUE,999999,0);
    -- buff:setScriptID(76);
end

function class:takeBitSkill(unit)
    if self.bitRank < 4 then
        self:addBit(unit);
        return;
    end
    self.isFollow = false;
    local buff = unit:getTeamUnitCondition():addCondition(1,17,self.SKILL_RATE,999999,0);
    buff:setScriptID(76);
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."max",true);
end

function class:takeBitSkill2(unit)
    if self.bitRank < 4 then
        self:addBit(unit);
        return;
    end
    self.isFollow = false;
    -- local buff = unit:getTeamUnitCondition():addCondition(1,17,self.SKILL_RATE,999999,0);
    -- buff:setScriptID(76);
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."max2",true);
end

function class:attackEnd(unit)
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."idle"..self.bitRank,true);
end

function class:skillEnd(unit)
    self.orbit:takeAnimation(0,"hide",false);
    self.bitRank = 0;
    self.orbit = nil;
    if self.isRage then
        self:addBit(unit);
    end
end

function class:inEnd()
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."idle"..self.bitRank,true);
end

function class:outEnd()
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."in"..self.bitRank,true);
end

--===========================================================================================================================

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

--===========================================================================================================================

function class:getRage(unit)
    self.spValue = 200;
    self.isRage = true;
    summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.cyan);
end

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:innerAddBit(self.gameUnit,args.arg);
    return 1;
end

class:publish();

return class;