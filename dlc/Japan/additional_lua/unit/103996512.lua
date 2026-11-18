local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒_刀神ルアン", version=1.3, id=103996512});
class:inheritFromUnit("103997512");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.abilityTime = 100
    self.buffTime = 15
    self.raceTypeCount = 0
    self.skillRate = 0.05

    --種族カウント
    self.raceBox = {}
    for i = 0,8 do
        self.raceBox[i] = false
    end

    self:setBuffBoxList()
    return 1
end


class:publish();

return class;