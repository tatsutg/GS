local class = summoner.Bootstrap.createUnitClass({label="満艦飾マコ", version=1.5, id=102206412});

--バフカウンター配列


class.BUFF_ID = 10220;

function class:start(event)
    self.gameUnit = event.unit;
    event.unit:setCutinSE2("SE_BATTLE_012_CUTIN_KLK_MAKO");
    --"se_battle_012_cutin_klk_mako"
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
    
    if cond ~= nil and cond:getPriority() <= 150 then
        unit:getTeamUnitCondition():removeCondition(cond);
        local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,150,20,34);
        newCond:setGroupID(1022);
        newCond:setPriority(150);
    elseif cond == nil then
        local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_ID,29,150,20,34);
        newCond:setGroupID(1022);
       
        newCond:setPriority(150);
       
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
