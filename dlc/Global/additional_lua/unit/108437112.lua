local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ラインハルト", version=2.8, id=108437112});

function class:firstIn(event)
    event.unit:setNextAnimationName("in2");
    event.unit:setNextAnimationEffectName("empty");
    return 0;
end


class:publish();

return class;
