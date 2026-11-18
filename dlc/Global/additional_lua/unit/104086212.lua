local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒超ロゼッタ", version=1.3, id=104086212});
class:inheritFromUnit("104087212");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    --self.weaponAddSP = 150
    --if event.unit:getParameter("weaponFlg") == "" then
    --    event.unit:setParameter("weaponFlg","true")
    --end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("weaponFlg") == "true" then
        event.unit:setParameter("weaponFlg","false")
        if self:findWeapon(event.unit,50315800) then
            event.unit:addSPWithPvpCorrection(self.weaponAddSP)
        end
    end
    return 1
end

function class:findWeapon(unit,weaponSkillId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponSkillId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 1;
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    return 1;
end


class:publish();

return class;