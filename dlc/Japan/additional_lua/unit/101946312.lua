local class = summoner.Bootstrap.createUnitClass({label="ヴォーグ", version=1.5, id=101946312});

--バフカウンター配列
class.icon_Table = 
{
    1, --  1
    2, --  2
    3, --  3
    4, --  4
    11 --  5
}

class.BUFF_VALUE = 20;

function class:start(event)
    self.gameUnit = event.unit;
    self.buffCount = 0;
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
    if event.spineEvent == "addCondition" then
        event.unit:getTeamUnitCondition():addCondition(101943,108,200,10,113);
        event.unit:getTeamUnitCondition():addCondition(101944,103,200,10,0);
        event.unit:getTeamUnitCondition():addCondition(101945,27,-100,10,0);
        event.unit:getTeamUnitCondition():addCondition(101946,33,100,10,0);
    end
    return 1;
end

function class:addBuff(unit,buffCount)
    local buff = unit:getTeamUnitCondition():addCondition(10194,22,buffCount * self.BUFF_VALUE,999999,176);
    buff:setNumber(self.icon_Table[buffCount]);
    unit:getTeamUnitCondition():addCondition(101942,17,buffCount * self.BUFF_VALUE,999999,0);
    unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
