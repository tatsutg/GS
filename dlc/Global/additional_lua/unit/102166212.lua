local class = summoner.Bootstrap.createUnitClass({label="リアナ", version=1.5, id=102166212});

class.BUFF_ARGS = {
    ID = 10216,
    EFID = 22,
    VALUE = 100,
    DURATION = 15,
    ICON = 11
}


function class:start(event)
    self.gameUnit = event.unit;
    self.isCounter = false;
    self.repulse = false;

    return 1;
end

function class:takeDamageValue(event)
    if self.isCounter then
        self.isCounter = false;
        if self:getIsControll(event.unit) then
            self:getRepulse(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1);
        end
        return 0;
    elseif self.repulse then
        return 0;
    end
    return event.value;
end

function class:takeBreakDamageValue(event)
    if self.isCounter then
        self.isCounter = false;
        if self:getIsControll(event.unit) then
            self:getRepulse(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1);
        end
        return 0;
    elseif self.repulse then
        return 0;
    end
    return event.value;
end

function class:takeDamage(event)
    repulse = false;
    return 1;
end

function class:takeSkill(event)
    if event.index ~= 1 then
        self:checkBuff(event.unit);
        self.isCounter = false;
        self.repulse = false;
    end
    return 1;
end

function class:excuteAction(event)
    self.repulse = false;
    return 1;
end

function class:run(event)
    if event.spineEvent == "counterStart" then
        self.isCounter = true;
    end

    if event.spineEvent == "counterEnd" then
        if self:getIsControll(event.unit) then
            self:counterEnd(event.unit)
        end
    end

    if event.spineEvent == "eventLost" then
        self:eventLost(event.unit);
    end

    if event.spineEvent == "buffEnd" then
        self:buffEnd(event.unit);
    end

    if event.spineEvent == "repulseEnd" then
        self:repulseEnd(event.unit);
    end

    return 1;
end

function class:counterEnd(unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    if self:getIsControll(unit) then
        self:repulseFaild(unit);
    end
    self.isCounter = false;
end

function class:eventLost(unit)
    self:repulseFaild(unit);
    self.isCounter = false;
end

function class:getRepulse(unit)
    unit:setAnimation(0,"counter",false);
    unit:takeAnimationEffect(0,"counter",false);
    self.repulse = true;
end

function class:repulseFaild(unit)
    unit:takeAnimation(0,"counterMiss",false); --ActiveSKILLはからになる
    unit:setActiveSkill(0); --入れ直す
    unit:takeAnimationEffect(0,"counterMiss",false);
end

function class:repulseEnd(unit)
    self.repulse = false;
end


function class:checkBuff(unit)
    if self.repulse and self:getIsControll(unit) then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        self:addBuff(unit)
    end
end

function class:addBuff(unit)
    --buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ARGS.ID,self.BUFF_ARGS.EFID,self.BUFF_ARGS.VALUE,self.BUFF_ARGS.DURATION,self.BUFF_ARGS.ICON);
    -- unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:buffEnd(unit)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS.ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

function class:receive1(args)
    if args.arg == 0 then
        self:repulseFaild(self.gameUnit);
    else
        self:getRepulse(self.gameUnit);
    end
    return 1;
end


function class:receive2(args)
    -- self:addBuff(self.gameUnit);
    return 1;
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end


class:publish();

return class;
