local class = summoner.Bootstrap.createUnitClass({label="桑原", version=2.6, id=107306412});

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    event.unit:getTeamUnitCondition():addCondition(10730,0,0,99999,0);
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.waves >= 2 then
        event.unit:getTeamUnitCondition():addCondition(10730,0,0,99999,0);
    end
    return 1
end

class:publish();

return class;