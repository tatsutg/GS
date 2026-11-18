local class = summoner.Bootstrap.createEnemyClass({label="すらい", version=1.3, id=2006139});


function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
    summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.magenta);
    return 1;
end



class:publish();

return class;