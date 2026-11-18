local class = summoner.Bootstrap.createUnitClass({label="イーグル", version=1.3, id=103075312});

class.HEAT_TIME = 60;
class.ADD_RATE = 900;
class.TRUE_EQ_RATE = 1.875;

class.HATE_BUFFS = {
    [0] = {
        ID = 102263,
       BUFF_ID = 12,
       VALUE = 100,
       DURATION = 60,
       ICON = 179,
       SCRIPT = 102,
       SCRIPTVALUE1 = 100,
       SCRIPTVALUE2 = 100000000,
       GROUP_ID = 103076312,
       PRIORITY = 100
    },
    [1] = {
        ID = 102264,
       BUFF_ID = 27,
       VALUE = -100,
       DURATION = 60,
       ICON = 0
    },
    [2] = {
        ID = 102265,
       BUFF_ID = 54,
       VALUE = 100,
       DURATION = 60,
       ICON = 0
    },
    [3] = {
        ID = 102266,
       BUFF_ID = 59,
       VALUE = 100,
       DURATION = 60,
       ICON = 0
    }
}



class.ARTS_BUFF = {
   ID = 103071,
   BUFF_ID = 98,
   VALUE = 8000,
   DURATION = 25,
   ICON = 24,
   EFFECT = 1
}

class.ARTS_BUFF2 = {
   ID = 103071,
   BUFF_ID = 98,
   VALUE = 12000,
   DURATION = 25,
   ICON = 24,
   EFFECT = 1
}

function class:start(event)
    self.gameUnit = event.unit;
    self.isOverHeat = false;
    event.unit:setParameter("307_Avenger","0")
    self.skillCounter = 0;
    self.aura = nil;
    self.heatTimer = 0;
    self.count = 0;
    self.gage = nil;
    self.nowAnimationNum = 0;
    self.gageRate = 1.25;
    self.checkEqip = false;
    self.isInit = false;
    self.startTrueArts = false;
    self.effective = false;

    return 1;
end


function class:startWave(event)
    if self.effective and self.isOverHeat then
        if self:isControllTarget(event.unit) then
            self:finishOverHeat(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        end
    end
    self.startTrueArts = false;
    return 1;
end

function class:initGage(event)
    self.isInit = true;
    if self.gage == nil then
        self.gage = self.gameUnit:addOrbitSystemWithFile("10307gage","0");
        self.gage:takeAnimation(0,"base",true);
        self.gage:setAnimation(3,"0",true);
    end
    --self.skill3DamageRate = event.unit:getBurstSkill2():getDamageRate();

    local isPlayer = event.unit:getisPlayer();
    if isPlayer then
        self.gage:getSkeleton():setScaleX(-1);
    end
end



function class:takeDamageValue(event)
    self:checkEQ(event.unit);
    if not self.isOverHeat then
        self.count = self.count + 1 * self.gageRate;
    end
    if self.count >= 100 then
        if self:isControllTarget(event.unit) then
            self:overHeat(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
    end
    return event.value;
end

function class:attackDamageValue(event)
    if self.startTrueArts then
        self.effective = true;
        self.startTrueArts = false;
    end
    return event.value;
end

function class:takeDamage(event)
    if self.effective and self.isOverHeat then
        if self:isControllTarget(event.unit) then
            self:finishOverHeat(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        end
    end
    self.startTrueArts = false;
    return 1;
end

function class:checkEQ(unit)
    if self.checkEqip then
        return;
    end
    self.checkEqip = true;
    if unit:getTeamUnitCondition():findConditionWithID(50239800) ~= nil then
        self.gageRate = self.TRUE_EQ_RATE;
    end
end

function class:update(event)
    
    if self.isOverHeat then
        self:auraControl(event.unit);
        self:heatCountUp(event.unit,event.deltaTime);
    end
    self:gageControl(event.unit);
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if not self.isInit then
        self:initGage(event);
    end
    return 1;
end



function class:takeSkill(event)
    if event.index == 3 then
        if self.isOverHeat then
            event.unit:setNextAnimationName("skill3_2");
            event.unit:setNextAnimationEffectName("skill3_2");
            self.effective = false;
            self.startTrueArts = true;
        end
    end
    return 1;
end

function class:run(event)
    -- if event.spineEvent == "takeOverHeat" and self:isControllTarget(event.unit) then
    --     self:overHeat(event.unit);
    --     megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    -- end
    if event.spineEvent == "finish" and self:isControllTarget(event.unit) then
        self:finishOverHeat(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
    end

    if event.spineEvent == "addBarrier" and self.isOverHeat then
        -- self:execAddBuff(event.unit,self.ARTS_BUFF);
    end
    return 1;
end

--====================================================================================================================
function class:overHeat(unit)
    if self.isOverHeat then
        self:finishOverHeat(unit);
    end
    self.isOverHeat = true;
    unit:setParameter("307_Avenger","1")
    self.skillCounter = 0;
    self.count = 100;
    self.aura = unit:addOrbitSystem("aura");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"aura",true);
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
    self:addBuffs(unit,self.HATE_BUFFS);

    self.gage:takeAnimation(1,"light",true);
    self.gage:takeAnimation(2,"spark",false);
    --unit:getBurstSkill2():setDamageRate(self.skill3DamageRate + self.ADD_RATE);
end

function class:heatCountUp(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    self.heatTimer = self.heatTimer + deltaTime;
    self.count = self.count - deltaTime * 100/self.HEAT_TIME;
    if self.heatTimer >= self.HEAT_TIME then
        self:finishOverHeat(unit);
    end
end

function class:finishOverHeat(unit)
    if not self.isOverHeat then
        return;
    end
    self.isOverHeat = false;
    unit:setParameter("307_Avenger","0")
    self.heatTimer = 0;
    self:auraEnd(unit);
    self.gage:takeAnimation(1,"none",true);
    self.gage:takeAnimation(0,"base",true);
    self.count = 0;
    --unit:getBurstSkill2():setDamageRate(self.skill3DamageRate);
    self:removeBuffs(unit,self.HATE_BUFFS);
    self.effective = false;
end

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v);
    end
end

function class:removeBuff(unit,table)
    local buff = unit:getTeamUnitCondition():findConditionWithID(table.ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

--====================================================================================================================



function class:auraControl(unit)
    if self.aura == nil then
        return;
    end
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");


    local isPlayer = unit:getisPlayer();
    if not isPlayer then
        targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
    end

    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
end

function class:auraEnd(unit)
    self.aura:takeAnimation(0,"empty",false);
    self.aura = nil;
end



function class:gageControl(unit)
    if self.gage == nil then
        return;
    end
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");

    local isPlayer = unit:getisPlayer();
    if not isPlayer then
        targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
    end

    self.gage:setPosition(targetx,targety);
    self.gage:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY() + 80);
    local animationNum = self.count/5;
    self.gage:setZOrder(9999);

    if self.isOverHeat then
        animationNum = math.ceil(animationNum);
    else
        animationNum = math.floor(animationNum);
    end
    if animationNum > 20 then
        animationNum = 20;
    end
    if animationNum ~= self.nowAnimationNum then
        self.gage:setAnimation(3,""..animationNum,true);
        self.nowAnimationNum = animationNum;
    end
    
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
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
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
  
    local buff = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    buff:setGroupID(buffBox.GROUP_ID);
    buff:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       buff:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end

--====================================================================================================================
function class:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end
    return false;
end

--====================================================================================================================
function class:receive1(args)
    self:overHeat(self.gameUnit);
    return 1;
end

function class:receive2(args)
    self:finishOverHeat(self.gameUnit)
    return 1;
end

class:publish();

return class;