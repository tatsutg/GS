local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒バルハラ", version=1.3, id=100586312});


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "BG_powerarea"  then
    event.unit:addOrbitSystemWithFile("10058ef","BG_powerarea")
    end
    return 1
end


class:publish();

return class;