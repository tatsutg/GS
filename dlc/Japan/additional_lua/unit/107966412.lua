local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒蛇崩乃音", version=1.3, id=107966412});
class:inheritFromUnit("107967412");

function class:define()
    self.skill1SpValue = 15
    self.startDashSpValue = 25
end

class:publish();

return class;