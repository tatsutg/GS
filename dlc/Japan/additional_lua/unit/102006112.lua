local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ジェラルド", version=2.6, id=102006112});

function class:start(event)
    self.gameUnit = event.unit;
    self.iconUpdateTimer = 0;
    self.BUFF_ID = 2001;
    self.count = 0
    return 1;
end

function class:startWave(event)
    if event.waves == 1 then
        event.unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,179);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    event.unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,179);
    return 1;
end

function class:update(event)
    ---バフアイコン数値更新
    self.iconUpdateTimer = self.iconUpdateTimer + event.deltaTime;
    if self.iconUpdateTimer > 0.1 then
        self:updateBuffIcon(event.unit);
        self.iconUpdateTimer = 0;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---復活から5秒間は死なない
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID)
    if cond ~= nil then
        if not megast.Battle:getInstance():isPvp() then
            if self:isControll(event.unit) then
                event.unit:setHP(1)
                return 0
            end
        else
            if cond:getTime() > 4 and self:isControll(event.unit) then
                event.unit:setHP(1)
                return 0
            end
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    self:addBuff(event.unit);
    event.unit:updateStatus();
    return 1
end

function class:addBuff(unit)
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,5,179);
    buff:setNumber(5);
end

function class:updateBuffIcon(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
    if cond ~= nil and cond:getTime() < 6 then
        local num = math.ceil(cond:getTime());
        cond:setNumber(num);
        megast.Battle:getInstance():updateConditionView();
    end
end

function class:isControll(unit)
    local ret = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
    if megast.Battle:getInstance():isPvp() then
        ret = true;
    end
    return ret;
end

class:publish();
return class;