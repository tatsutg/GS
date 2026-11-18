local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="限界突破用ハクロウ", version=1.3, id=103563311});
class:inheritFromUnit("103566311");

function class:removeConditions(unit,typeIds)
    local FLG = false
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for i,typeId in ipairs(typeIds) do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                    FLG = true
                end
            end
        end
    end
    if FLG then
        unit:addSPWithPvpCorrection(30)
    end
end

class:publish();

return class;