local child = summoner.Bootstrap.createEnemyClass({label="メリア", version=1.3, id=200380047});
child:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
child.ATTACK_WEIGHTS = {
    ATTACK1 = 90,
    ATTACK2 = 10
}

--使用する奥義とその確率
child.SKILL_WEIGHTS = {
    SKILL2 = 100
}

child.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3
}

child.BARRIER_ID = 101071;
child.BARRIER_EFID = 98;
child.BARRIER_VAUE = 9999*10000;
child.BARRIER_DURATION = 10;
child.BARRIER_ICON = 24;
child.BARRIRE_ANIMATION = 1;
child.SPVALUE_ORIGIN = 20;

child.FIRST_BARRIER_HP = 70/100;
child.SECOND_BARRIER_HP = 30/100;

child.BARRIER_STATES = {
    NONE = 0,
    FIRST = 1,
    SECOND = 2
}


--=========================================================================================================================================
--デフォルトのイベント

function child:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = self.SPVALUE_ORIGIN;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.messages = summoner.Text:fetchByEnemyID(200370043);
    self.allUnits = {};
    self.isStop = false;
    self.barrierState = self.BARRIER_STATES.NONE;


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        {
            HP = 70,isUsed = false,MARKER = event.unit:addNumHpMarker(0.7)
        },
        {
            HP = 30,isUsed = false,MARKER = event.unit:addNumHpMarker(0.3)
        }
    }
    return 1;
end

function child:startWave(event)
    -- event.unit:addSP(100);
    return 1;
end

function child:update(event)
    self:chekcBarrier(event.unit);
    if event.unit:getTeamUnitCondition():findConditionWithID(self.BARRIER_ID) ~= nil then
        event.unit:setReduceHitStop(11,1);--自動結界がある間はヒットストップ無効Lv11　完全無効
        event.unit:setHitStopTimeSelf(0);
        event.unit:takeGrayScale(0.99);
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

function child:takeAttack(event)

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
    self.attackCanseller = true;
    self:addSP(event.unit);
    self:attackActiveSkillSetter(event.unit,event.index);
    
    return 1
end



function child:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        event.unit:takeSkill(event.index);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,event.index);
        return 0;
    end
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index == 2 then
        event.unit:setBurstState(kBurstState_active);
    end
    return 1
end

function child:attackDamageValue(event)
    if self.isStop and event.enemy:getParentTeamUnit() == nil then
        event.enemy:takeGrayScale(0.01);
        table.insert(self.allUnits,event.enemy:getIndex());
    end
    return event.value;
end

function child:run (event)
    if event.spineEvent == "theWorld" then return self:theWorld(event.unit) end
    if event.spineEvent == "worldEnd" then return self:worldEnd(event.unit) end
    if event.spineEvent == "move" then return self:move(event.unit) end
    return 1;
end

--=========================================================================================================================================
--攻撃判断周りの

function child:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    --もしattack2が選択されたらスキルを出す　ユニットを無理やりボスとして使っているためアニメーションが少ないので
    if tonumber(attackIndex) == 2 then
        unit:takeSkill(1);
    else
        unit:takeAttack(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    end

    
    return 0;
end

function child:addSP(unit)
    if megast.Battle:getInstance():isHost() then
        unit:addSP(self.spValue);
        self.spValue = self.SPVALUE_ORIGIN;
    end
    return 1;
end

--=========================================================================================================================================
--時止め周りの処理

function  child:theWorld(unit)
 
    self.isStop = true;
    
    return 1;
end

function child:move(unit)
    for i = 1,table.maxn(self.allUnits) do
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(self.allUnits[i],true);
        if uni ~= nil and uni:getisPlayer() ~= unit:getisPlayer() then
            uni:getSkeleton():setPosition(0,uni:getPositionY() + 300);
            uni:setPosition(unit:getPositionX() + math.random(350)*-1 - 250,uni:getPositionY());
        end
    end
    return 1;
end

function child:worldEnd(unit)
    for i = 1,table.maxn(self.allUnits) do
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(self.allUnits[i],true);
        if uni ~= nil then
            uni:takeGrayScale(0.99);
        end
    end
    self.allUnits = {};

    self.isStop = false;
    return 1;
end

--=========================================================================================================================================
--自動結界周りの処理

function child:chekcBarrier(unit)
    --今回はゲスト側でもとりあえず域値を跨いだら即座にバリアを張って、それで間に合わなければホストから同期されるようにする
    local takeBarrier = false;
    if self.barrierState == self.BARRIER_STATES.NONE and summoner.Utility.getUnitHealthRate(unit) < self.FIRST_BARRIER_HP then
        self.barrierState = self.BARRIER_STATES.FIRST;
        self:addBarrier(unit,self.barrierState);
        takeBarrier = true;
    elseif self.barrierState == self.BARRIER_STATES.FIRST and summoner.Utility.getUnitHealthRate(unit) < self.SECOND_BARRIER_HP then
        self.barrierState = self.BARRIER_STATES.SECOND;
        self:addBarrier(unit,self.barrierState);
        takeBarrier = true;
    end

    if megast.Battle:getInstance():isHost() and takeBarrier then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,self.barrierState);
    end
end

function child:addBarrier(unit)
    unit:setHitStopTimeSelf(0);
    unit:takeGrayScale(0.99);
    self.spValue = unit:getNeedSP();
    if unit:getTeamUnitCondition():findConditionWithID(self.BARRIER_ID) == nil then
        summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
        summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.magenta);
        unit:getTeamUnitCondition():addCondition(
            self.BARRIER_ID,
            self.BARRIER_EFID,
            self.BARRIER_VAUE,
            self.BARRIER_DURATION,
            self.BARRIER_ICON,
            self.BARRIRE_ANIMATION
        );
    end
    
end

--=========================================================================================================================================


function child:receive3(args)
    self.barrierState = args.arg;
    self:addBarrier(self.gameUnit);
    return 1;
end

child:publish();

return child;