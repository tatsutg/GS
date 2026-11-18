local child = summoner.Bootstrap.createEnemyClass({label="フィーナ", version=1.3, id=200370038});
child:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
child.ATTACK_WEIGHTS = {
    ATTACK1 = 100
}

--使用する奥義とその確率
child.SKILL_WEIGHTS = {
    SKILL2 = 100
}

child.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL2 = 2,
    SKILL3 = 3
}



function child:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.skillCheckFlg2 = false;
    self.messages = summoner.Text:fetchByEnemyID(200370043);

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end

function child:update(event)
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1
end

function child:takeAttack(event)
    if summoner.Utility.getUnitHealthRate(event.unit) < 0.5 and not self.isRage and megast.Battle:getInstance():isHost() then
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
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function child:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    
    -- if self.isRage then
    --     skillIndex = 3;
    -- end
    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function child:takeSkill(event)
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
    if self:getIsBoss(event.unit) then
        for i=0,7 do
            local target = event.unit:getTeam():getTeamUnit(i);
            if target ~= nil and target ~= event.unit and target:getBaseID3() == 4 and megast.Battle:getInstance():isHost() then
                target:callLuaMethod("forceSkill",1.5);
            end
        end
    end
    return 1
end

function child:forceSkill()
    self.gameUnit:takeSkill(0);
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

function child:getRage(unit)
    summoner.Utility.messageByEnemy(self.messages.mess1,5,summoner.Color.yellow,36);
    summoner.Utility.messageByEnemy(self.messages.mess2,5,summoner.Color.yellow,26);
    unit:getTeamUnitCondition():addCondition(200370043,17,50,999999,26,17);
    unit:getTeamUnitCondition():addCondition(200370044,0,50,999999,36);
    self.spValue = 40;
    self.isRage = true;
end

function child:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

child:publish();

return child;