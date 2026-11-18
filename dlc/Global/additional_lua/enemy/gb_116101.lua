local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB弔花の魔女ポーラ", version=1.3, id="gb_116101"});
class:inheritFromEnemy("gbBossBase");

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "shot" then
        self:shot(event.unit) 
    end
    return 1;
end

function class:shot(unit)
    local shot =unit:addOrbitSystemInsightRotation("1_attack_1_TAMA","empty",1,-120,0,180,0);
    --shot:setDamageRateOffset(3.21)
    return 1;
end

class:publish();

return class;