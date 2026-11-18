local class = summoner.Bootstrap.createEnemyClass({label="ロストイベント用ジェラルド", version=1.3, id=200570013});

class.HEAL_VALUE = 50;
class.SP_VALUE = 200;
class.BUFF_DURATION = 5;
class.BUFFID = 2001;

function class:start(event)
    self.gameUnit = event.unit;
    self.iconUpdateTimer = 0;
    self.regeneTimer = 0;
    self.regeneDuration = 0;
    self.targetHP = event.unit:getCalcHPMAX();
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and event.unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179);
    end
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
    return 1;
end

function class:startWave(event)
    if event.unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179);
    end
    return 1;
end

function class:update(event)
    self.iconUpdateTimer = self.iconUpdateTimer + event.deltaTime;
    if self.iconUpdateTimer > 0.1 then
        self:updateBuffIcon(event.unit);
        self.iconUpdateTimer = 0;
    end
    if self.regeneDuration > 0 and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self.regeneDuration = self.regeneDuration - event.deltaTime;
        self.regeneTimer = self.regeneTimer + event.deltaTime;
        if self.regeneTimer > 1 then
            self.regeneTimer = 0;
            self:regenation(event.unit);
        end
    end

    return 1;
end

function class:excuteAction(event)
    if not self:isBuddyStillAlive(event.unit) then
        event.unit:setParameter("lastLeave","TRUE"); 
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(cond);
        end
        event.unit:setHP(0);
    end
    return 1;
end


function class:dead(event)
    if event.unit:getParameter("lastLeave") ~= "TRUE" and self:isControll(event.unit) then
        self:addBuff(event.unit)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        event.unit:setHP(1);
        return 0;
    end

    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
    if cond ~= nil and self:isControll(event.unit) then
        event.unit:setHP(1);
        return 0;
    end
    
    return 1;
end

function class:addBuff(unit)
    self.targetHP = unit:getCalcHPMAX();
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,self.BUFF_DURATION,179);
    buff:setNumber(5);
    self.regeneDuration = self.BUFF_DURATION;
    self.regeneTimer = 1;
    unit:setParameter("lastLeave","TRUE"); 
end

function class:updateBuffIcon(unit)
    if unit:getParameter("lastLeave") ~= "TRUE" then
        return;
    end
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
    if cond ~= nil then
        local num = math.ceil(cond:getTime());
        cond:setNumber(num);
        megast.Battle:getInstance():updateConditionView();
    end
end

function class:regenation(unit)
    unit:addSP(self.SP_VALUE/self.BUFF_DURATION);
    local rate = (100 + unit:getTeamUnitCondition():findConditionValue(115) + unit:getTeamUnitCondition():findConditionValue(110))/100;
    unit:takeHeal(rate * self.targetHP * self.HEAL_VALUE/(100 * self.BUFF_DURATION));
end

function class:receive1(args)
    self:addBuff(self.gameUnit,0);
    return 1;
end

function class:isControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:isBuddyStillAlive(unit)
    
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 199 then
            return true;
        end
    end
    return false;
    
end



class:publish();

return class;