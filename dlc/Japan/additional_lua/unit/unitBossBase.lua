local class = summoner.Bootstrap.createUnitClass({label="unit name", version=1.9, id=12345});

--攻撃内容が自動同期されないタイプ（ユニットボス）用のクラス

--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
--オーバーライド必須！！//
--////////////////////

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL1 = 3,
    SKILL2 = 4
}


--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

function class:addSP(unit)
    if megast.Battle:getInstance():isHost() then
        unit:addSP(self.spValue);
    end
    return 1;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////



function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    unit:takeAttack(tonumber(attackIndex));
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
        unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////



function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
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
        unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);
    return 1
end

function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end
--===================================================================================================================

--===================================================================================================================
--マルチ同期//
--//////////
function class:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeAttackFromHost(unit,index)
    self.fromHost = true;
    unit:takeAttack(index);
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    unit:takeSkill(index);
end

--===================================================================================================================
class:publish();

return class;
