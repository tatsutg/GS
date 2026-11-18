local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ナターシャ：スピリチア05", version=1.3, id=104056512});
class:inheritFromUnit("104057512");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill2Value = -15
    self.skill2Time = 15
    self:setBuffBoxList(event.unit)
    self.skill2FLG = false
    self.skill5FLG = false
    self.skill5FLG_HIT = false
    self.skill5AddConditionList = {}
    return 1
end

class:publish();

return class;