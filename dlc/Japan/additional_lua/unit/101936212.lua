local class = summoner.Bootstrap.createUnitClass({label="すらい", version=1.5, id=101936212});


function class:takeSkill(event)
    if event.index == 3 and summoner.Utility.getUnitHealthRate(event.unit) <= 0.5 then
        event.unit:setNextAnimationName("skill4");
    end
    return 1;
end

class:publish();

return class;
