local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒エドラム", version=1.3, id=101576412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.attackChecker = false
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackChecker then
        self.attackChecker = true;
        return self:attackBranch(event.unit);
    end
    self.attackChecker = false;
    return 1
end

function class:attackBranch(unit)
    if unit:getBurstPoint() < 200 then
        unit:takeAttack(2);
    else
        unit:takeAttack(1);
    end
    return 0;
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then
        self:addSP(event.unit)
    end
    return 1
end

function class:addSP(unit)
    unit:addSPWithPvpCorrection(20);
end

class:publish();

return class;