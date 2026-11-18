--@additionalEnemy,100071820,100964250
local instance = summoner.Bootstrap.createUnitClass({label="unit name", version=1.3, id=501002213});

--ガイアユニットボス
--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
--skill2とattack2で味方全員にバリアを張る
--一定時間ごとに発動するattack2でミキュオンを召喚する　たまにゴル猫キングが混じる
--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

--使用する通常攻撃とその確率
instance.attackWeights = {
    attack5 = 50,
    attack3 = 50,
    attack4 = 50
}

--使用する奥義とその確率
instance.skillWeights = {
    skill1 = 50,
    skill2 = 50
}

--攻撃や奥義に設定されるスキルの番号
instance.activeSkills = {
    attack5 = 1,
    attack2 = 2,
    attack3 = 3,
    attack4 = 4,
    skill1 = 5,
    skill2 = 6
}

instance.fromHost = false;
instance.gameUnit = nil;
instance.spValue = 20;
instance.attack2Timer = 60;
instance.attack2Recast = 60;

instance.consts = {
    summonEnemyID = 100071820,--ミキュオン
    summonEnemyID2 = 100964250,--ゴル猫キング
    barrierBuffID = 10171,
    barrierBuffEFID = 98,
    barrierValue = 200000,
    barrierDuration = 20,
    barrierIcon = 24,
    barrierAnimation = 1

};

instance.messages = summoner.Text:fetchByUnitID(501005213);

--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

function instance:start(event)
    self.gameUnit = event.unit;
    return 1;
end

function instance:startWave(event)
    summoner.Utility.messageByEnemy(self.messages.mess1,5,summoner.Color.green,45);
    return 1;
end

function instance:update(event)
    self.attack2Timer = self.attack2Timer + event.deltaTime;
    return 1;
end

function instance:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "summon" and megast.Battle:getInstance():isHost() then return self:summon(event.unit) end
    if event.spineEvent == "addBarrier" and megast.Battle:getInstance():isHost() then 
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return self:addBarrier(event.unit) 
    end
    return 1;
end

function instance:addSP(unit)
    if megast.Battle:getInstance():isHost() then
        unit:addSP(self.spValue);
    end
    return 1;
end

function instance:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if not(enemy == nil )then
            enemy:setHP(0);
        end
    end
    return 1;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////

instance.attackCheckFlg = false;

function instance:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.attackWeights);
    local attackIndex = string.gsub(attackStr,"attack","");
    if self.attack2Timer > self.attack2Recast and summoner.Utility.getUnitHealthRate(unit) < 0.66 then
        attackIndex = 2;
        self.attack2Timer = 0;
    end
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function instance:takeAttack(event)
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
    return 1
end

function instance:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["attack"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////

instance.skillCheckFlg = false;

function instance:skillBranch(unit)
    local condValue = unit:getTeamUnitCondition():findConditionValue(98);
    if condValue > 0 then
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1);
    else
        unit:takeSkill(2);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,2);
    end
    
    return 0;
end

function instance:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);
    return 1
end

function instance:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.activeSkills["skill"..index]);
end

--===================================================================================================================

--===================================================================================================================
--マルチ同期//
--//////////
function instance:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function instance:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end

function instance:receive3(args)
    self:addBarrier(self.gameUnit);
    return 1;
end

function instance:takeAttackFromHost(unit,index)
    self.fromHost = true;
    unit:takeAttack(index);
end

function instance:takeSkillFromHost(unit,index)
    self.fromHost = true;
    unit:takeSkill(index);
end

--===================================================================================================================


--===================================================================================================================
function instance:summon(unit)
    --0~2の場所が空席ならミキュオンを出せる ４％の確率でゴル猫になる
    for i=0,2 do
        if unit:getTeam():getTeamUnit(i) == nil then
            if LuaUtilities.rand(100) <= 4 then
                unit:getTeam():addUnit(i,self.consts.summonEnemyID2);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                
            else
                unit:getTeam():addUnit(i,self.consts.summonEnemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
               
            end
        end
    end
    return 1;
end

function instance:addBarrier(unit)
    -- local aquaCnt = select("#",summoner.Utility.findUnitsByCallBack(self.findUnitCallBack,unit:getisPlayer()));
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        local value = self.consts.barrierValue;
        if target ~= nil then
            if target == unit then
                value = value * 3;
            end
            if target:getBaseID3() == 7 then
                target:getTeamUnitCondition():addCondition(101712,17,200,999999,0,17);
                target:getTeamUnitCondition():addCondition(101713,27,-100,999999);
            elseif target:getBaseID3() == 96 then
                target:setDeadDropSp(150);
            end
            target:getTeamUnitCondition():addCondition(
                self.consts.barrierBuffID,
                self.consts.barrierBuffEFID,
                value,
                self.consts.barrierDuration,
                self.consts.barrierIcon,
                self.consts.barrierAnimation
            );
        end
    end
    return 1;
end

function instance.findUnitCallBack(unit)
    return unit:getElementType() == kElementType_Aqua;
end


--===================================================================================================================



instance:publish();

return instance;
