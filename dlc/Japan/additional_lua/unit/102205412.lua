local class = summoner.Bootstrap.createUnitClass({label="満艦飾マコ", version=1.5, id=102205412});

--バフカウンター配列


class.BUFF_ID = 10220;

function class:start(event)
    self.gameUnit = event.unit;
    return 1;
end



function class:run(event)
    if event.spineEvent == "addBuff" and self:getIsControll(event.unit) then
        self:addBuff(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    return 1;
end


function class:addBuff(unit)
       
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(1022);--スキルCTアップ系のグループIDのバフ
    
    if cond ~= nil and cond:getPriority() <= 120 then
        unit:getTeamUnitCondition():removeCondition(cond);
        local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,120,10,34);
        newCond:setGroupID(1022);
        newCond:setPriority(120);
    elseif cond == nil then
        local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,120,10,34);
        newCond:setGroupID(1022);
       
        newCond:setPriority(120);
       
    end
        
end


function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
