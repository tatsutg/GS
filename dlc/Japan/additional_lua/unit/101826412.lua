local class = summoner.Bootstrap.createUnitClass({label="フリード", version=1.5, id=101826412});

--バフカウンター配列
class.icon_Table = 
{
   165, --  1
    166, --  2
    167, --  3
    168, --  4
    174 --  5
}

class.BUFF_VALUE = 20;

function class:start(event)
    self.gameUnit = event.unit;
    self.buffCount = 0;
    return 1;
end

function class:attackElementRate(event)
    local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if skillType ~= 2 and skillType ~= 1 then
        return event.value;
    end
    local el = event.enemy:getElementType();
    if el == kElementType_Light then
        event.value = megast.Battle:getInstance():getElementalRate(5,4)
        --summoner.Utility.messageByEnemy(event.value)
    end
    
    return event.value;
end

function class:attackDamageValue(event)
    event.value = event.value - event.value * (event.enemy:getTeamUnitCondition():findConditionValue(65) / 100);
    if event.value < 1 then
    	event.value = 1;
    end
    return event.value;
end

function class:run(event)
    if event.spineEvent == "addBuff" then
        if (event.unit:isMyunit() or (event.unit:getisPlayer() == false and megast.Battle:getInstance():isHost())) and self.buffCount <= 4 then
            self.buffCount = self.buffCount + 1;
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffCount);
        end
    end
    return 1;
end

function class:addBuff(unit,buffCount)
    local buff = unit:getTeamUnitCondition():addCondition(10182,22,buffCount * self.BUFF_VALUE,999999,self.icon_Table[buffCount]);
    unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
