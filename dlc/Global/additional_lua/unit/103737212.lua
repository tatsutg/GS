local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒水着フェン", version=1.3, id=103737212});

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if event.unit:getHP() == 0 then
        event.unit:setNextAnimationName("damageOut")
    end
    return 1
end

class:publish();

return class;