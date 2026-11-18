local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒水着クロエ", version=1.3, id=107997412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.weaponAddSP = 100
    if event.unit:getParameter("weaponFlg") == "" then
        event.unit:setParameter("weaponFlg","true")
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("weaponFlg") == "true" then
        event.unit:setParameter("weaponFlg","false")
        if self:findWeapon(event.unit,50310700) then
            event.unit:addSPWithPvpCorrection(self.weaponAddSP)
        end
    end
    return 1
end

function class:findWeapon(unit,weaponSkillId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponSkillId);
    return buff ~= nil
end

class:publish();

return class;