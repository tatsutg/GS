local class = summoner.Bootstrap.createUnitClass({label="ラム", version=1.3, id=107365312});

function class:start(event)
    return 1;
end

function class:startWave(event)
    if event.waves == 1 and not megast.Battle:getInstance():isPvp() then
        local luck = event.unit:getLuckLevel();
        event.unit:addSPWithPvpCorrection(luck);
    end
    return 1;
end


class:publish();

return class;