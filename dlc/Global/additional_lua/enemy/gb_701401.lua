local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB焔撃の神装姫ソレイユ", version=1.3, id="gb_701401"});
class:inheritFromEnemy("gbBossBase");

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "skill1Shot" then self:skill1Shot(event.unit) end
    return 1;
end

function class:skill1Shot(unit)
    unit:addOrbitSystemInsightRotation("1_skill1_boll","1_skill1_explosion",1,0,100,180,0);
    return 1;
end

class:publish();

return class;
