local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒神星リザ", version=1.3, id=103647412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    ---エーテルリキャスト_テスト用
    if event.unit:getParameter("aetherRecast") ~= "DONE" then
        for itemSkillIndex = 0, 2 do
            local itemSkill = event.unit:getItemSkill(itemSkillIndex)
            if itemSkill ~= nil then
                itemSkill:setRecastCount(1)
            end
        end
        event.unit:setParameter("aetherRecast","DONE")
    end
    event.unit:setRecastVoice("VOICE_PARTY")
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

class:publish();

return class;