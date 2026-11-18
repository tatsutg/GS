local class = summoner.Bootstrap.createUnitClass({label="エンド", version=1.5, id=101906412});

class.SP_VALUE = 100;
class.FUTURE_VISION_TIME = 60;
class.CRITICAL_BUFF_VALUE = 20;

function class:start(event)
	self.gameUnit = event.unit;
	self.buffCompleated = false;
	self.message = self.TEXT.mess1 ~= nil and self.TEXT.mess1 or " ";
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and not megast.Battle:getInstance():isPvp() then
        if not self:checkParametor(event.unit,"startDash") then
            self:startDash(event.unit);
            event.unit:setParameter("startDash","TRUE");
        end
    end
	return 1;
end

function class:startWave(event)
    if not megast.Battle:getInstance():isPvp() then
        event.unit:setParameter("startDash","TRUE");
        self:startDash(event.unit);
    end
    return 1;
end

function class:update(event)
    local totalTime = BattleControl:get():getTime();
    if totalTime >= self.FUTURE_VISION_TIME and not self.buffCompleated and megast.Battle:getInstance():getBattleState() == kBattleState_active then
    	self:futureVision(event.unit);
    end
    return 1;
end

function class:startDash(unit)
    unit:addSPWithPvpCorrection(self.SP_VALUE);
end

function class:futureVision(unit)
    if unit:getLevel() < 90 then
        return;
    end
    if not self:checkParametor(unit,"futureVision") then
        unit:setParameter("futureVision","TRUE");
        unit:addSPWithPvpCorrection(self.SP_VALUE);

    end
    unit:getTeamUnitCondition():addCondition(10190,22,self.CRITICAL_BUFF_VALUE,9999999,11);
    unit:playSummary(self.message,true);
    self.buffCompleated = true;
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end



class:publish();

return class;
