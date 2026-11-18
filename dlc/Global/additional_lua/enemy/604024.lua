local child = summoner.Bootstrap.createEnemyClass({label="グラード", version=1.3, id=604024});
child:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
child.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50
}

--使用する奥義とその確率
child.SKILL_WEIGHTS = {
    SKILL2 = 100
}

--攻撃や奥義に設定されるスキルの番号
child.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK3 = 2,
    ATTACK4 = 3,
    ATTACK5 = 4,
    SKILL2 = 7
}

function child:takeSkill(event)
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
    if self:getIsBoss(event.unit) then
        for i=0,7 do
            local target = event.unit:getTeam():getTeamUnit(i);
            if target ~= nil and target ~= event.unit then
                target:takeSkill(0);
            end
        end
    end
    return 1
end

function child:addSP(unit)
    if megast.Battle:getInstance():isHost() and self:getIsBoss(unit) then
        unit:addSP(self.spValue);
    end
    return 1;
end

function child:getIsBoss(unit)
    local boss = megast.Battle:getInstance():getTeam(false):getBoss();
    if boss == nil then
        return false;
    end
    return boss == unit;
end

child:publish();

return child;