local child = summoner.Bootstrap.createUnitClass({label="氷ドラゴン", version=1.3, id=4900085});
child:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
child.ATTACK_WEIGHTS = {
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
child.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

--攻撃や奥義に設定されるスキルの番号
child.ACTIVE_SKILLS = {
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

--定数
child.RAGE_COOLTIME = 25;
child.MESSAGES = summoner.Text:fetchByUnitID(500122213);



--======================================================================================================================================
function child:start(event)
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    self.gameUnit = nil;
    self.rageTimer = 25;
    self.iceOrbit = nil;
    self.isRage = false;
    self.rageAttackNum = 6;
    self.isFreeze = false;

    event.unit:setSPGainValue(0);
    self.gameUnit = event.unit;
    return 1;
end

function child:startWave(event)
    summoner.Utility.messageByEnemy(self.MESSAGES.mess7,5,summoner.Color.cyan,21);
    return 1;
end

function child:update(event)
    if not self.isRage then
        self.rageTimer = self.rageTimer + event.deltaTime;
    end
    if not self.isFreeze then
        local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
        if ice ~= nil then
            self.isFreeze = true;
            self:showFreezeMessage();
        end
    else
        local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
        if ice == nil then
            self.isFreeze = false;
        end
    end
    return 1;
end

function child:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if not self.isRage and summoner.Utility.getUnitHealthRate(unit) < 0.8 and self.rageTimer >= self.RAGE_COOLTIME then
        attackIndex = self.rageAttackNum;
    end
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function child:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    if event.index == 6 then
        event.unit:showPopText(self.MESSAGES.mess6);
    end
    return 1
end

function child:takeDamageValue(event)
    local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        return 1;
    end
    return event.value;
end

function child:takeBreakDamageValue(event)
    local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        return 1;
    end
    return event.value;
end

function child:takeBreake(event)
    self:removeIce(event.unit);
    self.isRage = false;
    return 1;
end

function child:run (event)
    if event.spineEvent == "addSP" then  self:addSP(event.unit) end
    
    if event.spineEvent == "addIce" then 
        if megast.Battle:getInstance():isHost() then
            self:addIce(event.unit)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
    end
    
    if event.spineEvent == "iceControll" then self:iceControll(event.unit) end
    
    if event.spineEvent == "selfFreeze" then 
        if megast.Battle:getInstance():isHost() then
            self:selfFreeze(event.unit)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        end
    end
    return 1;
end

function child:addIce(unit)
    if self.iceOrbit ~= nil then
        return;
    end
    self:getRage(unit);
    self.iceOrbit = unit:addOrbitSystem("ice_floor_in",0);
    self.iceOrbit:takeAnimation(0,"ice_floor_in",true);
    self.iceOrbit:setZOrder(0);
    self.iceOrbit:setActiveSkill(8);
end

function child:iceControll(orbit)
    if self.iceOrbit ~= nil then
        self.iceOrbit:takeAnimation(0,"ice_floor_cur",true);
    end
end

function child:removeIce(unit)
    if self.iceOrbit ~= nil then
        self.iceOrbit:takeAnimation(0,"ice_floor_out",false);
        self.iceOrbit = nil;
        summoner.Utility.messageByEnemy(self.MESSAGES.mess2,5,summoner.Color.cyan);
    end
end

function child:getRage(unit)
   self.isRage = true;
   self.rageTimer = 0;
   summoner.Utility.messageByEnemy(self.MESSAGES.mess1,5,summoner.Color.cyan);
end

function child:selfFreeze(unit)
    self:addIce(unit);
    unit:getTeamUnitCondition():addCondition(500121,96,1,15,86,7);
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2020","attack1");
    orbit:getSkeleton():setScaleX(-1);
    orbit:setActiveSkill(5);

end

function child:showFreezeMessage()
    summoner.Utility.messageByEnemy(self.MESSAGES.mess3,5,summoner.Color.cyan,20);
    summoner.Utility.messageByEnemy(self.MESSAGES.mess4,5,summoner.Color.cyan,20);
    summoner.Utility.messageByEnemy(self.MESSAGES.mess5,5,summoner.Color.cyan,35);
end


--===================================================================================================================

--===================================================================================================================
--マルチ同期//
--//////////
function child:receive1(args)
    self:addIce(self.gameUnit);
    return 1;
end


function child:receive2(args)
    self:selfFreeze(self.gameUnit);
    return 1;
end



--===================================================================================================================

child:publish();

return child;
