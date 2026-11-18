--@additionalEnemy,2005648
local class = summoner.Bootstrap.createEnemyClass({label="けいん", version=1.3, id=2005645});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK9 = 50,
    ATTACK3 = 50,
    ATTACK1 = 50,
    ATTACK0 = 50
}

class.ATTACK_WEIGHTS_RAGE = {
    ATTACK4 = 10,
    ATTACK5 = 50,
    ATTACK6 = 50,
    ATTACK7 = 10
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
    ATTACK6 = 6,
    ATTACK7 = 7,
    ATTACK8 = 8,
    ATTACK9 = 2,--兵士呼びのモーション違いvar
    SKILL1 = 9,
    SKILL2 = 10,
    SKILL4 = 11
}

class.ANIMATION_STATE = {
    IDLE = 0,
    ATTACK = 1,
    BACK = 5,
    DAMAGE = 6,
    FRONT = 7
}

class.SUMMON_ENEMY = 2005648;
class.SUMMON_ENEMY_POSITION = 4;

class.ANTIBREAK_BUFF = {
     ID = 20056451,
     EFID = 27,
     VALUE = -50,
     DURAION = 99999,
     ICON = 0
}

class.ANTICRITICAL_BUFF = {
     ID = 20056452,
     EFID = 23,
     VALUE = -1000,
     DURAION = 99999,
     ICON = 188
}



function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isSummoned = false;
    self.isFenSkillEnd = false;

    self.fenTimer = 0;
    self.soldirCounter = 0;


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setAttackDelay(0);
    event.unit:setSkillInvocationWeight(0);
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end

function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.yellow);
    summoner.Utility.messageByEnemy(self.TEXT.mess3,5,summoner.Color.red);
    return 0;
end

function class:update(event)
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    if summoner.Utility.getUnitHealthRate(event.unit) < 0.5 and not self.isRage then
        event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　100%軽減
    end

    if summoner.Utility.getUnitHealthRate(event.unit) < 0.2 and not self.isSummoned then
        self:addUnit(event.unit);
        self.isSummoned = true;
    end

    if not self.isFenSkillEnd and self.isSummoned and megast.Battle:getInstance():isHost() and self.fenTimer > 6 then

        self:takeFenSkill(self.gameUnit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end

    if self.isSummoned then
        self.fenTimer = self.fenTimer + event.deltaTime;
    end

    self.soldirCounter = self.soldirCounter + event.deltaTime;
    self:positionFix(event.unit);
    return 1;
end

function class:excuteAction(event)
    if self.startPositionX == nil then
        self.startPositionX = event.unit:getPositionX();
        self.startPositionY = event.unit:getPositionY();
    end
    self.attackCheckFlg = false;
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.ATTACK);

    return 1;
end

function class:takeIdle(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.IDLE);
    return 1;
end

function class:takeDamage(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.DAMAGE)
    return 1;
end

function class:takeFront(event)
    if self.isRage then
        event.unit:takeIdle();
        return 0;
    end
    return 1;
end

function class:takeBack(event)
    if self.isRage then
        event.unit:takeIdle();
        return 0;
    end
    return 1;
end

function class:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if not(enemy == nil )then
            enemy:setHP(0);
        end
    end
    return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);

    if self.isRage then
        attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS_RAGE);
    end

    local attackIndex = string.gsub(attackStr,"ATTACK","");

    --兵士呼びの分岐　前回の兵士呼びから3秒以上経っていたら他の行動を強制的に上書きして兵士呼び
    if not self.isRage and self.soldirCounter > 3 then
        attackIndex = 2;
        self.soldirCounter = 0;
    end

    --怒り移行攻撃の分岐　HPが５０％を切ったら他の行動を強制的に上書きして戦車に乗る
    if summoner.Utility.getUnitHealthRate(unit) < 0.5 and not self.isRage then
        attackIndex = 8;

        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,1);
    end 


    if tonumber(attackIndex) == 0 then
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1);
        return 0;
    end
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
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);

    --搭乗モーションではaddSPしない
    if event.index ~= 8 then
        self:addSP(event.unit);
    end

    return 1
end

function class:skillBranch(unit)
    local skillIndex = 2;
    if self.isRage then
        skillIndex = 4;
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
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
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:run(event)
    if event.spineEvent == "summon" then
        self:summon(event.unit,1);
    end
    if event.spineEvent == "summon2" then
        self:summon(event.unit,2);
    end
    return 1;
end


--=====================================================================================================================================

function class:summon(unit,index)
    if index == 1 then
        local orbitA = unit:addOrbitSystemWithFile("102176312","soldir1a");
        local orbitB = unit:addOrbitSystemWithFile("102176312","soldir1b");

        orbitA:setAutoZOrder(false);
        orbitB:setAutoZOrder(false);

        orbitA:setZOrder(-unit:getPositionY() + 3000 + 100);
        orbitB:setZOrder(-unit:getPositionY() + 3000 - 100);
    else
        local orbitA = unit:addOrbitSystemWithFile("102176312","soldir2a");
        local orbitB = unit:addOrbitSystemWithFile("102176312","soldir2b");

        orbitA:setAutoZOrder(false);
        orbitB:setAutoZOrder(false);

        orbitA:setZOrder(-unit:getPositionY() + 3000 + 100);
        orbitB:setZOrder(-unit:getPositionY() + 3000 - 100);

        
    end
end

--=====================================================================================================================================

function class:getRage(unit)
    unit:setInvincibleTime(5);
    self.isRage = true;
    unit:setRange_Min(0);
    unit:setRange_Max(9999);
    self:removeAllBadstatus(unit);
    unit:resumeUnit();
    unit:setRaceType(5);
    unit:setHPBarHeightOffset(10000);
    unit:updateHPBar();
    unit:setSize(3);

    unit:getTeamUnitCondition():addCondition(
        self.ANTIBREAK_BUFF.ID,
        self.ANTIBREAK_BUFF.EFID,
        self.ANTIBREAK_BUFF.VALUE,
        self.ANTIBREAK_BUFF.DURAION,
        self.ANTIBREAK_BUFF.ICON
    );

    -- unit:getTeamUnitCondition():addCondition(
    --     self.ANTICRITICAL_BUFF.ID,
    --     self.ANTICRITICAL_BUFF.EFID,
    --     self.ANTICRITICAL_BUFF.VALUE,
    --     self.ANTICRITICAL_BUFF.DURAION,
    --     self.ANTICRITICAL_BUFF.ICON
    -- );     
    summoner.Utility.messageByEnemy(self.TEXT.mess4,5,summoner.Color.green);
    summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.yellow);
    summoner.Utility.messageByEnemy(self.TEXT.mess6,5,summoner.Color.red);
end

function class:addUnit(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    if unit:getTeam():getTeamUnit(self.SUMMON_ENEMY_POSITION) == nil then
        local enemy = unit:getTeam():addUnit(self.SUMMON_ENEMY_POSITION,self.SUMMON_ENEMY);
    end
end

function class:takeFenSkill(unit)
    if megast.Battle:getInstance():getTeam(false):getTeamUnit(self.SUMMON_ENEMY_POSITION) ~= nil then
        self.isFenSkillEnd = true;
        summoner.Utility.messageByEnemy(self.TEXT.mess5,5,summoner.Color.green);
        megast.Battle:getInstance():getTeam(false):getTeamUnit(self.SUMMON_ENEMY_POSITION):takeSkill(2);
    end
end

--=====================================================================================================================================
--見た目関連

function class:positionFix(unit)
    if not self.isRage then
        return;
    end
    unit:getSkeleton():setPosition(0,0);
    if self.startPositionX ~= nil then
        unit:setPositionX(self.startPositionX);
        unit:setPositionY(self.startPositionY);
    end
end

function class:animationSwitcher(unit,animState)
    if not self.isRage then
        return;
    end
    unit:setSetupAnimationName("seuUpTank"); 
    if animState == self.ANIMATION_STATE.IDLE then
        unit:setNextAnimationName("idle-tank");
    elseif animState == self.ANIMATION_STATE.DAMAGE then
        unit:setNextAnimationName("damage-tank"); 
    end
end

--=====================================================================================================================================
function class:removeAllBadstatus(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
        end
    end
end

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:takeFenSkill(self.gameUnit);
    return 1;
end


class:publish();

return class;