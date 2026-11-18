local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="Q10_ミーナス", version=2.0, id=2064445});

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    event.unit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
end

function class:receive4(args)
    self.gameUnit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 1
end


class:publish();

return class;