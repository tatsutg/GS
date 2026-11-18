local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴェナ", version=1.3, id=103926311});
class:inheritFromUnit("103927311");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.buffTime = 20
    self.skill2BuffValue = 1500
    self.skill3BuffValue = 100
    self.abilityBuffRate = -0.1
    self.gameUnit = event.unit

    self.auraLevel = 1
    self:setSkillFlg()
    self:setBuffBoxList()
    self:setRP(event.unit)
    return 1
end

class:publish();

return class;