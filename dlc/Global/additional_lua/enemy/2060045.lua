local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ２後編_Q10_水着イリヤ（巨大）", version=2.0, id=2060045});


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        size = 4
    })
    self:dump(self.GD)
    self.gameUnit = event.unit;
    event.unit:getSkeleton():setScale(self.GD.size);
    event.unit:setHPBarHeightOffset(10000);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.startPositionX == nil then
        self.startPositionX = event.unit:getPositionX();
        self.startPositionY = event.unit:getPositionY();
        event.unit:setRange_Min(0);
        event.unit:setRange_Max(1000);
    end
    event.unit:setPositionX(self.startPositionX);
    event.unit:setPositionY(self.startPositionY);
    return 1
end




class:publish();

return class;