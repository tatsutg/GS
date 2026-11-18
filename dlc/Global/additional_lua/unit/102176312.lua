local class = summoner.Bootstrap.createUnitClass({label="けいん", version=1.5, id=102176312});

--バフカウンター配列


class.BUFF_ID = 10217;

function class:start(event)
    self.gameUnit = event.unit;
    self.buffCount = self:getCont(event.unit);
    self:addBuff(event.unit,self.buffCount);
    return 1;
end


function class:run(event)
    if event.spineEvent == "coinToss" then
        self:coinToss(event);
    end
    return 1;
end

function class:coinToss(event)
    if (event.unit:isMyunit() or (event.unit:getisPlayer() == false and megast.Battle:getInstance():isHost())) then
        if self.buffCount >= 3 then
            self.buffCount = 0;
            self:addBuff(event.unit,0);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffCount);
        elseif LuaUtilities.rand(100) <= 50 then
            self.buffCount = self.buffCount + 1;
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffCount);
            self:addSP(event.unit);
        else
            self.buffCount = 0;
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffCount);
        end
    end
    return 1;
end

function class:addSP(unit)
    unit:addSPWithPvpCorrection(unit:getNeedSPMax());
end

function class:setCount(unit,count)
    unit:setParameter("counter",""..count); 
end

function class:getCont(unit)
    if unit:getParameter("counter") ~= nil and unit:getParameter("counter") ~= "" then
        local str = unit:getParameter("counter");
        return tonumber(str);
    end
    return 0;
end

function class:addBuff(unit,buffCount)
    if buffCount == 0 then
        summoner.Utility.removeUnitBuffByID(unit,self.BUFF_ID);
        self:setCount(unit,0);
    else
        local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,0,1,999999,176);
        buff:setNumber(buffCount);
        megast.Battle:getInstance():updateConditionView();
        self:setCount(unit,buffCount);
    end
    --unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
