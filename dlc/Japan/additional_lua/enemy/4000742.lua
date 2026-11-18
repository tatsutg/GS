local class = summoner.Bootstrap.createEnemyClass({label="コロック", version=1.7, id=4000742});

class.DROP_SP = 800

function class:startWave(event)
    event.unit:setDeadDropSp(self.DROP_SP);
    return 1;
end

class:publish();

return class;