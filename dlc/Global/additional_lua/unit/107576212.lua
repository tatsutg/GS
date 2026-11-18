local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒グレイ", version=1.3, id=107576212});


function class:startWave(event)
    if not megast.Battle:getInstance():isPvp() then
        local luck = event.unit:getLuckLevel();
        event.unit:addSPWithPvpCorrection(luck);
    end
    return 1
end


class:publish();

return class;