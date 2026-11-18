local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒和装シュナ", version=1.3, id=108086412});
class:inheritFromUnit("108087412");

function class:timerCheck(unit)
    return false
end

function class:setSkillAddSP()
    self.skillAddSP = {
        [1] = 35,
        [2] = 40,
        [3] = 45
    }
end

class:publish();

return class;