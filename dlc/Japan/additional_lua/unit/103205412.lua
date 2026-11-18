local class = summoner.Bootstrap.createUnitClass({label="ノエル", version=1.3, id=103205412});

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:enemyCheck(event.unit)
    return 1
end

function class:enemyCheck(unit)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(10320502);
            if cond ~= nil then
                local stage = cond:getValue5()
                if stage == 0 then stage = 1 end
                myTeamUnit:setParameter("320_Kusabi",""..stage)
            else
                myTeamUnit:setParameter("320_Kusabi",""..0)
            end
        end
    end
end

class:publish();

return class;