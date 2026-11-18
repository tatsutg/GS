local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒ライラ", version=1.3, id=103366412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self:setDefaultBurstSkillRate(event.unit)
    return 1
end

function class:setDefaultBurstSkillRate(unit)
    if unit:getParameter("defaultDamageRate") ~= "" then
        self.defaultDamageRate = unit:getParameter("defaultDamageRate")
    else
        self.defaultDamageRate = unit:getBurstSkill2():getDamageRate()
        unit:setParameter("defaultDamageRate",self.defaultDamageRate)
    end
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate + (self:elementCount() * 150))
    end
    return 1
end

function class:elementCount()
    local myTeam = megast.Battle:getInstance():getTeam(self.gameUnit:getisPlayer())
    local elementTable = {}
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= self.gameUnit and myTeamUnit ~= nil then
            elementTable[myTeamUnit:getElementType()] = true
        end
    end
    return self:tableCount(elementTable)
end

function class:tableCount(tbl)
    local n = 0
    for _ in pairs (tbl) do
        n = n + 1
    end
    return n
end

class:publish();

return class;