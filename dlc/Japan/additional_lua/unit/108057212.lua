local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ベータ", version=1.3, id=108057212});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_ShieldBuff" then
        event.unit:addOrbitSystem("ShieldBuff",0)
    end
    return 1
end

class:publish();

return class;