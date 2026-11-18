local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="転スラ後編オージュ", version=1.4, id=2065420});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    local bossfire = BattleControl:get():addAnimation("FIRE","FIRE3",true);
    bossfire:setPositionX(-450);
    bossfire:setPositionY(-30);
    bossfire:setZOrder(30000);
    bossfire:setScale(1.2);
    return 1
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    event.unit:setDefaultPosition(-400 , -100);
    event.unit:setPositionX(-400);
    event.unit:setPositionY(-100);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setDefaultPosition(-400 , -100);
    event.unit:setPositionX(-400);
    event.unit:setPositionY(-100);
    BattleControl:get():focusCamera(0,0,0,0.72,4,0,1);
    BattleControl:get():setCameraDefaultScale(0.72);
    return 1
end

class:publish();

return class;