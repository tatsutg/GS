local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒ロン", version=1.3, id=103557212});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

class:publish();

return class;