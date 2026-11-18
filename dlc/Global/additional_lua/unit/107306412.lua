local class = summoner.Bootstrap.createUnitClass({label="桑原", version=1.3, id=107306412});

function class:start(event)
    return 1;
end

function class:startWave(event)
    if not megast.Battle:getInstance():isPvp() then
        if event.waves == 1 then
            local luck = event.unit:getLuckLevel();
            event.unit:addSPWithPvpCorrection(luck);
        end
        event.unit:addSPWithPvpCorrection(80);
    end
    return 1;
end


class:publish();

return class;