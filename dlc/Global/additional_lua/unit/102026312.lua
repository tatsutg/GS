local class = summoner.Bootstrap.createUnitClass({label="フォスレ", version=1.5, id=102026312});

--バフカウンター配列
class.icon_Table = 
{
    1, --  1
    2, --  2
    3, --  3
    4, --  4
    11 --  5
    
}

class.icon_Table2 = 
{
    1, --  1
    2, --  2
    11 --  10
}
class.BUFF_VALUE = 0;

function class:start(event)
    self.gameUnit = event.unit;
    self.buffCount = 0;
    self.buffCount2 = 0;
    return 1;
end


function class:run(event)
    if event.spineEvent == "addBuff" then
        if (event.unit:isMyunit() or (event.unit:getisPlayer() == false and megast.Battle:getInstance():isHost())) and self.buffCount <= 4 then
            self.buffCount = self.buffCount + 1;
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffCount);
        end
    end
    if event.spineEvent == "addBuff2" then
        if (event.unit:isMyunit() or (event.unit:getisPlayer() == false and megast.Battle:getInstance():isHost())) and self.buffCount2 <= 2 then
            self.buffCount2 = self.buffCount2 + 1;
            self:addBuff2(event.unit,self.buffCount2);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.buffCount2);
        end
    end
    return 1;
end

function class:addBuff(unit,buffCount)
    local buff = unit:getTeamUnitCondition():addCondition(102021,13,buffCount * self.BUFF_VALUE,999999,3);
    buff:setNumber(self.icon_Table[buffCount]);
    megast.Battle:getInstance():updateConditionView();
    -- unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:addBuff2(unit,buffCount)
    local buff = unit:getTeamUnitCondition():addCondition(102022,25,buffCount * self.BUFF_VALUE,999999,9);
    buff:setNumber(self.icon_Table2[buffCount]);
    megast.Battle:getInstance():updateConditionView();
    -- unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:addBuff2(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
