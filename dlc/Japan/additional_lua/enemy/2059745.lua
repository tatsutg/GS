local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ２中編_Q10 キングピキュオン(どでか)", version=1.3, id=2059745});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        size = 7
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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    event.unit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
end

function class:receive4(args)
    self.gameUnit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
end

class:publish();

return class;