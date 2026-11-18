local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒カナリア", version=2.7, id=103716212});
class:inheritFromUnit("103717212");

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.num = 2
    self.jacketColor = {
        [2] = "",
        [3] = "_G",
        [1] = "_R"
    }
    self.skillFLG = false
    self.skill2FLG = false
    self:setBuffBoxList()
    self.maxBP = 200
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[self.num])
    megast.Battle:getInstance():updateConditionView();
    return 1
end

class:publish();

return class;