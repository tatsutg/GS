local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="るろ剣_前半_Q10_羅将オロチ", version=2.4, id=2067346});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        size = 1.3
    })
    self:dump(self.GD)
    self.gameUnit = event.unit;
    event.unit:getSkeleton():setScale(self.GD.size);
    --event.unit:setHPBarHeightOffset(10000);
    return 1
end


class:publish();

return class;