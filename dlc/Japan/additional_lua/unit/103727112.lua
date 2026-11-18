local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒水着イリス", version=1.3, id=103727112});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.burstPointMax = 300
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "fireWork" then
        event.unit:addOrbitSystem("BG",0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        if not megast.Battle:getInstance():isPvp() then
            event.unit:addSP(math.ceil((self.burstPointMax - event.unit:getBurstPoint()) /2))
        else
            ---pvp特別補正
            event.unit:addSP(math.ceil((self.burstPointMax - event.unit:getBurstPoint()) /2 / 3))
        end
    end
    return 1
end

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