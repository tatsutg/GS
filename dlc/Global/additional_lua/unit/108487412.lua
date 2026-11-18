local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒美遊（神王フォーム）", version=2.3, id=108487412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    if event.unit:getParameter("aetherRecast") ~= "DONE" then
        for itemSkillIndex = 0, 2 do
            local itemSkill = event.unit:getItemSkill(itemSkillIndex)
            if itemSkill ~= nil then
                itemSkill:setRecastCount(1)
            end
        end
        event.unit:setParameter("aetherRecast","DONE")
    end
    return 1
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0
end

class:publish();

return class;
