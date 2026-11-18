local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴェルザード", version=1.9, id=103906112});
class:inheritFromUnit("103907112");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.CHECK_ID = 103906
    self.checkTimer = 0
    self.skill1Flg = false
    self.skillAddSPValue = 15
    self:setBuffBoxList()
    return 1
end


class:publish();

return class;