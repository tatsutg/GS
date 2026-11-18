local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ゾルダス", version=1.3, id=101306112});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    if event.unit:getParameter("defaultDamage") ~= "" then
        self.defaultDamage = event.unit:getParameter("defaultDamage")
    else
        self.defaultDamage = event.unit:getBurstSkill2():getDamageRate()
        event.unit:setParameter("defaultDamage",self.defaultDamage)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        self:addDamage(event.unit,self.defaultDamage + ((event.unit:getCalcDefence() / 100) * 5))
    end
    return 1
end

function class:addDamage(unit,value)
    --防御力*3を威力に上乗せ
    unit:getBurstSkill2():setDamageRate(value)
end

class:publish();

return class;