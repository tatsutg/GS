local instance = summoner.Bootstrap.createUnitClass({label="unit name", version=1.3, id=101714211});

--ガイア
--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


instance.consts = {
    barrierBuffID = 2000,
    barrierBuffEFID = 98,
    barrierValue = 800,
    barrierDuration = 20,
    barrierIcon = 24,
    barrierAnimation = 1

};


--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

function instance:start(event)
    self.gameUnit = event.unit;
    return 1;
end

function instance:run (event)
    if event.spineEvent == "addBarrier" and megast.Battle:getInstance():isHost() then
        local aquaCnt = select("#",summoner.Utility.findUnitsByCallBack(self.findUnitCallBack,event.unit:getisPlayer()));
    	megast.Battle:getInstance():sendEventToLua(self.scriptID,1,aquaCnt);
    	return self:addBarrier(event.unit,aquaCnt) 
    end
    return 1;
end




--===================================================================================================================
--マルチ同期//
--//////////


function instance:receive1(intparam)
    self.addBarrier(self.gameUnit,intparam);
    return 1;
end


--===================================================================================================================


--===================================================================================================================

function instance:addBarrier(unit,aquaCnt)
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        local value = self.consts.barrierValue * aquaCnt;
        if target ~= nil then
            local cond = target:getTeamUnitCondition():findConditionWithGroupID(2000);
            if cond ~= nil then
                target:getTeamUnitCondition():removeCondition(cond);
            end
            local buff = target:getTeamUnitCondition():addCondition(
                self.consts.barrierBuffID,
                self.consts.barrierBuffEFID,
                value,
                self.consts.barrierDuration,
                self.consts.barrierIcon,
                self.consts.barrierAnimation
            );
            buff:setGroupID(2000);
        end
    end
    return 1;
end

function instance.findUnitCallBack(unit)
    return unit:getElementType() == kElementType_Aqua;
end


--===================================================================================================================

instance:publish();

return instance;
