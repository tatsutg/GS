local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴェルザード", version=1.9, id=103906112});
class:inheritFromUnit("103907112");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill1Flg = false
    self.skillAddSPValue = 15
    self.killFlg = {}   --[敵index] = true HPが0に達する一撃を入れた敵
    self:setBuffBoxList()
    return 1
end


class:publish();

return class;