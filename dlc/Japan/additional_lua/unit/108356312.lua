local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒魂魄妖夢", version=2.6, id=108356312});
class:inheritFromUnit("108357312");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList();
    self.gameUnit = event.unit;
    event.unit:setDeadEffectWithFile("EAST_dead","dead");

    --固有アビリティ対応
    local ID = 52000 + (event.unit:getIndex() * 10);
    local buff = event.unit:getTeamUnitCondition():addCondition(ID,238,0,999999,0);
    buff:setScriptID(520);
    buff:setValue1(3);
    buff:setValue2(40364600);
    buff:setValue3(15);
    buff:setValue4(34);
    buff:setValue5(29);
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end


class:publish();

return class;