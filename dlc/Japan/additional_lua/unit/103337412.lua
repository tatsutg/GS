local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒ルアーナ", version=2.0, id=103337412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill5FLG = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG then
        self.skill5FLG = false
        local ground = event.unit:addOrbitSystemWithFile("103337412","groundEF");
        ground:setZOrder(0);
        ground:getSkeleton():setScaleX(1.2)
        ground:getSkeleton():setScaleY(1.2)
        ground:setPositionY(ground:getPositionY() -50);
        ground:setHitStopSync(true)
        ground:setStopConditionSync(true)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self.skill5FLG = true
    end
    return 1
end


class:publish();

return class;