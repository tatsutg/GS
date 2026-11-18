local class = summoner.Bootstrap.createUnitClass({label="バクー", version=1.9, id=103086512});

class.STAN = {
    [1] = {
        ID = 1030801,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 5,
        ICON = 79
    }   
  
}

class.STAN_MINI = {--とりあえず動きを止めるようの短時間スタン
    [1] = {
        ID = 1030801,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 2,
        ICON = 79
    }   
  
}

class.TARGET = {
    [1] = {
        ID = 1030804,
        BUFF_ID = 0,
        VALUE = 1,
        DURATION = 99999,
        ICON = 181
    }   
  
}


class.PT_BUFF = {
    [1] = {
        ID = 1030802,
        BUFF_ID = 17,
        VALUE = 300,
        DURATION = 20,
        ICON = 29,
        SCRIPT = 5
    },
    [2] = {
        ID = 1030803,
        BUFF_ID = 10,
        VALUE = 6,
        DURATION = 20,
        ICON = 36,
        GROUP_ID = 1034,
        PRIORITY = 120
    }
}

class.HIDE_TIME = 5;
class.ARTS_POINT = 50;
class.PAY_HP_RATE = 30;



function class:start(event)
    self.gameUnit = event.unit;
    self.targetIndex = -1;
    self.beforeTargetIndex = -1;
    self.artsGazeTimer = 0;
    self.artsStates = {};
    self.hideUnitIndexList = {};
    self.hideUnitTimers = {};
    self.hideUnitListOffset = 0;
    self.healPoint = 0;
    self.fixedTargetIndex = -1;


    return 1;
end

function class:run(event)
    if event.spineEvent == "eat" then
        self:eat(event.unit);
    end

    if event.spineEvent == "targetCheck" then
        self:targetCheck(event.unit);
    end


    if event.spineEvent == "addStan" then
        self:addStan(event.unit);
    end
    return 1;
end

function class:targetCheck(unit)
    if not self:getIsControll(unit) then
        return;
    end
    local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(self.fixedTargetIndex);
    if uni ~= nil then
        return;
    end

    for i=0,5 do
        local uni2 = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if uni2 ~= nil and uni2 ~= unit then
            self.fixedTargetIndex = i;
        end
    end
end

function class:addStan(unit)
    if not self:getIsControll(unit) then
        return;
    end
    if self.fixedTargetIndex == -1 then
        return;
    end
    self:execStan(unit,self.fixedTargetIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.fixedTargetIndex);
end

function class:execStan(unit,index)
    local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(index);
    if uni ~= nil then
        self:addBuffs(uni,self.STAN_MINI);
        megast.Battle:getInstance():updateConditionView()
    end
    
end


function class:eat(unit)
    if not self:getIsControll(unit) then
        return;
    end
    if self.fixedTargetIndex == -1 then
        return;
    end
    self:execEat(unit,self.fixedTargetIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.fixedTargetIndex);
end

function class:execEat(unit,index)
    local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(index);
    if uni ~= nil then
        self:addBuffs(uni,self.STAN);
        uni:setInvincibleTime(10);
        self.opacityTimer = 0;
        self.hideUnitListOffset = self.hideUnitListOffset + 1;--タイマーリストとインデックスリストがaddとかだとずれたらやなので、indexを直接指定してぶち込むよ
        self.hideUnitIndexList[self.hideUnitListOffset] = index;
        self.hideUnitTimers[self.hideUnitListOffset] = 0;
        self:switchUnitEffect(uni,false);
        self:addPTBuff(unit,index);
        
        self.healPoint = uni:getHP() * self.PAY_HP_RATE/100;

        local damage = uni:getHP() * self.PAY_HP_RATE/100;
        local targetHP = uni:getHP() - damage
        if targetHP <= 0 then
            targetHP = 1;
            damage = targetHP - 1
        end

        uni:setHP(targetHP);
        ---GB_EXボス用対応
        if megast.Battle:getInstance():isGrandBattleExBoss() then
            local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
            local sp = damage / rate
            uni:addSP(sp,false,false,true)
        end

        self:heal(unit);
        megast.Battle:getInstance():updateConditionView()
    end
    
end

function class:addPTBuff(unit,exc)
    for i=0,5 do
        local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil and i ~= exc then
            self:addBuffs(uni,self.PT_BUFF);
            uni:addSPWithPvpCorrection(self.ARTS_POINT);
        end
    end
end

function class:heal(unit)
    local rate = (100 + unit:getTeamUnitCondition():findConditionValue(126) + unit:getTeamUnitCondition():findConditionValue(110))/100
      local rate2 = (100 + unit:getTeamUnitCondition():findConditionValue(115))/100
      unit:takeHeal(self.healPoint * rate * rate2);
end

function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    self:artsGaze(event.unit,event.deltaTime);
    self:opacityControl(event.unit,event.deltaTime);
    if self.targetIndex == -1 then
        local index = -1
        for i = 0,6 do
            local myTeamUnit = event.unit:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit ~= event.unit then
                    index = myTeamUnit:getIndex()
                end
            end
        end
        event.unit:setParameter("308_Eat",index);
    else
        event.unit:setParameter("308_Eat",self.targetIndex);
    end
    return 1;
end

function class:opacityControl(unit,deltaTime)
    for i=0,table.maxn(self.hideUnitIndexList) + 1 do
        if self.hideUnitIndexList[i] ~= nil then
            self:changeOpacity(unit,i,deltaTime,false);
        end
    end
end

function class:changeOpacity(unit,targetIndex,deltaTime,isForceReset)
    self.hideUnitTimers[targetIndex] = self.hideUnitTimers[targetIndex] + deltaTime;
    local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(self.hideUnitIndexList[targetIndex]);
    if uni ~= nil then
        if self.hideUnitTimers[targetIndex] > self.HIDE_TIME or isForceReset then
            uni:setOpacity(255);
            uni:getSkeleton():setPositionY(600);
            self.hideUnitIndexList[targetIndex] = nil;
            self.hideUnitTimers[targetIndex] = nil;
            self:switchUnitEffect(uni,true);
            self:removeStanBuff(uni);
        else
            uni:setOpacity(0);
        end
    else
        self.hideUnitIndexList[targetIndex] = nil;
        self.hideUnitTimers[targetIndex] = nil;
    end
    
end

function class:releaceAll(unit)
    for i=0,table.maxn(self.hideUnitIndexList) + 1 do
        if self.hideUnitIndexList[i] ~= nil then
            self:changeOpacity(unit,i,0,true);
        end
    end
end

function class:removeStanBuff(unit)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.STAN[1].ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

function class:switchUnitEffect(unit,bool)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     cond:setUnitEffectVisible(bool)
  end
end

function class:artsGaze(unit,deltaTime)
    local skill = unit:getActiveBattleSkill();

    if not (skill ~= nil and skill:isBurst2()) then
        if self.targetIndex ~= self.fixedTargetIndex then
            self.fixedTargetIndex = self.targetIndex;
            self:targetChange(unit);
        end
    end
    
    for i = 0,5 do
        --指定されたインデックスでユニットを取得
        local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil and uni ~= unit then
            if uni:getBurstState() == kBurstState_active and uni:getBurstState() ~= self.artsStates[i] then
                self.targetIndex = i;
                
                if not (skill ~= nil and skill:isBurst2()) then
                    self.fixedTargetIndex = i;
                end
                
                if self.targetIndex ~= self.beforeTargetIndex then
                    self:targetChange(unit);
                end
            end
            self.artsStates[i] = uni:getBurstState();
        end

    end

    return 1;
end

function class:targetChange(unit)

    self.TARGET[1].ID = 10308040 + unit:getIndex();
    local uni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(self.beforeTargetIndex);
    if uni ~= nil then
        self:removeTargetBuff(uni);
    end

    local nextUni = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(self.fixedTargetIndex);
    if nextUni ~= nil then
        self:addBuffs(nextUni,self.TARGET);
    end
    self.beforeTargetIndex = self.fixedTargetIndex;
end

function class:removeTargetBuff(unit)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.TARGET[1].ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

function class:dead(event)
    self:releaceAll(event.unit);
    return 1;
end

function class:receive1(args)
    self:execEat(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:execStan(self.gameUnit,args.arg);
    return 1;
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:attackDamageValue_OrbitSystem(event)
   if event.enemy:getHP() - event.value <= 0 then
        event.unit:addSPWithPvpCorrection(10);
   end
   return event.value
end

function class:attackDamageValue(event)
   if event.enemy:getHP() - event.value <= 0 then
        event.unit:addSPWithPvpCorrection(10);
   end
   return event.value
end


--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       newCond:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
end


class:publish();

return class;