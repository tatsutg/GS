local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒モルク", version=2.5, id=104236212});
class:inheritFromUnit("104237212");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.ADD_SP_VALUE = 60
    self.isShinOugi = false
    --self:setBuffBoxList()
    return 1
end

class:publish();

return class;