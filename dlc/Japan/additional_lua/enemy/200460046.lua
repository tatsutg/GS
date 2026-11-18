local class = summoner.Bootstrap.createEnemyClass({label="リシュリー", version=1.3, id=200460046});
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
    self.isBacume = false;
    self.BacumeUnits = {};
    self.bacumeSpeed = 10;
        

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:update(event)
    --吸引中ならアップデートで吸引する
    if self.isBacume then
        for i = 1,table.maxn(self.BacumeUnits) do

            local targetUnit = self.BacumeUnits[i];
            if targetUnit ~= nil then
                local targetx = targetUnit:getPositionX();
                local thisx = event.unit:getPositionX();
                local distance = thisx - targetx;
                local oneFrame = 0.016666666;
                local moveSpeed = self.bacumeSpeed * event.deltaTime/oneFrame; --フレームレートで吸引距離が変わらないようにするためdeltaを60fpsで割って掛け算
                
                
                local sign = 1; --距離が＋かーか。１か−１になる
                if distance < 0 then
                    sign = -1;
                end
                
                
                targetUnit:setPosition(targetx + moveSpeed * sign,targetUnit:getPositionY());
                
            end
        end
    end
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
            if target ~= nil and target ~= event.unit and target:getBaseID3() == 185 and megast.Battle:getInstance():isHost() then
                target:callLuaMethod("forceSkill",0.2);
            end
        end
    end
    return 1
end

function class:run (event)
    if event.spineEvent == "forceSkill" then self:forceSkill() end
    if event.spineEvent == "Suction" then return self:Suction(event.unit) end
    if event.spineEvent == "SuctionEnd" then return self:SuctionEnd(event.unit) end
    if event.spineEvent == "addBuff" then return self:addBuff(event.unit) end
    return 1;
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
function class:Suction(unit)

    print("吸引開始");
    self.isBacume = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil then
            print("target is not nil");
            table.insert(self.BacumeUnits,uni);
        end
    end
    return 1;
end
function class:SuctionEnd(unit)
    self.isBacume = false;
    self.BacumeUnits = {};
    return 1;
end

function class:addBuff(unit)
    
    -- --攻撃アップ
    -- unit:getTeamUnitCondition():addCondition(101841,13,self.BUFF_VALUE,self.BUFF_DURATION,3);
    -- --防御アップ
    -- unit:getTeamUnitCondition():addCondition(101842,15,self.BUFF_VALUE,self.BUFF_DURATION,5);
    -- --最大HPアップ
    -- unit:getTeamUnitCondition():addCondition(101843,2,self.BUFF_VALUE,self.BUFF_DURATION,1);

    unit:playSummary(self.TEXT.mess1,true);
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
        if target ~= nil and target ~= unit and target:getBaseID3() == 185 then
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

class:publish();

return class;