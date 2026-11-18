local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="限界突破用花垣武道", version=1.3, id=107615111});

function class:startWave(event)
    if event.waves == 1 and event.unit:getLevel() >= 1 then
        local luck = event.unit:getLuckLevel();
        event.unit:addSPWithPvpCorrection(luck);
    end
    return 1;
end

class:publish();

return class;