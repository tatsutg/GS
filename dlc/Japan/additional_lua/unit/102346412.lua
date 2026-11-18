local class = summoner.Bootstrap.createUnitClass({label="daki", version=1.5, id=102346412});

--バフカウンター配列


class.BUFF_ID = 10708;

function class:start(event)
    self.gameUnit = event.unit;
    return 1;
end



function class:run(event)
    if event.spineEvent == "addBuff" and self:getIsControll(event.unit) then
        self:addBuffAll(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    return 1;
end

function class:addBuffAll(unit)
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i,true);
        if teamUnit ~= nil then
            self:addBuff(teamUnit);
        end
    end
end


function class:addBuff(unit)
       
    -- local cond = unit:getTeamUnitCondition():findConditionWithGroupID(1022);--スキルCTアップ系のグループIDのバフ
    
    -- if cond ~= nil and cond:getPriority() <= 120 then
    --     unit:getTeamUnitCondition():removeCondition(cond);
    --     local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,120,10,34);
    --     newCond:setGroupID(1022);
    --     newCond:setPriority(120);
    -- elseif cond == nil then
        local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,120,14,34);
    --     newCond:setGroupID(1022);
       
    --     newCond:setPriority(120);
       
    -- end
        
end


function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:addBuffAll(self.gameUnit);
    return 1;
end


class:publish();

return class;
