local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="貫いた理想サリサ", version=1.3, id=103146312});

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(10313603);
    if buff == nil then
        event.unit:setParameter("314_Effort","0")
    else
        local count = math.floor(buff:getValue() / 10)
        event.unit:setParameter("314_Effort",""..count)
    end
    return 1
end

class:publish();

return class;