local class = summoner.Bootstrap.createUnitClass({label="ラム", version=1.3, id=107365312});

function class:start(event)
    return 1;
end

class:publish();

return class;