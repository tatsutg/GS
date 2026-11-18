local class = summoner.Bootstrap.createEnemyClass({label="ごぶりん", version=1.3, id=4000512});


function class:startWave(event)
    event.unit:setDeadDropSp(300);
    return 1;
end



class:publish();

return class;