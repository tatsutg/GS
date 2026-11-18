local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ミゼット", version=2.3, id=104036412});
class:inheritFromUnit("104037412");

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        event.unit:setNextAnimationName("skill5")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill5")
        self.skill5FLG = true
        self:changeDamageText(true,event.unit)
    end
    return 1
end

function class:changeDamageText(isCamera,unit)
    if isCamera then
        unit:changeDamageTextLayerToCamera()
    else
        unit:changeDamageTextLayerToBattleField()
    end
end

class:publish();

return class;