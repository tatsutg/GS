local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="35章_EX1_終世神魔アグノフォボス", version=1.9, id=3505034});
class:inheritFromEnemy("3505035");

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    local backGate = event.unit:addOrbitSystemWithFile("50068back_gate","idle");
    backGate:takeAnimation(0,"idle",true);
    backGate:setPositionX(event.unit:getPositionX() + 300);
    backGate:setPositionY(200);
    backGate:setZOrder(99999);
    return 1
end


class:publish();

return class;