local class = summoner.Bootstrap.createEnemyClass({label="ごるねこごっど", version=1.3, id=4000812});


function class:startWave(event)
    event.unit:setDeadDropSp(300);
    return 1;
end



class:publish();

return class;