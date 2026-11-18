local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒イビルポーラ", version=1.3, id=103817312});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.spValue = 60
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        local myTeam = event.unit:getTeam();
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:removeConditionAddSP(myTeamUnit,90)
            end
        end
    end
    return 1
end

function class:removeConditionAddSP(unit,typeId)
    local FLG = false
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getConditionTypeAsInt() == typeId then
                cond:setTime(0) --バフ除去
                FLG = true
                break;
            end
        end
    end
    if FLG then
        unit:addSPWithPvpCorrection(self.spValue)
    end
end

class:publish();

return class;