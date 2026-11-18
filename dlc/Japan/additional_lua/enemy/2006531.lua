local class = summoner.Bootstrap.createEnemyClass({label="ぼーげん", version=1.3, id=2006531});


function class:startWave(event)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
    return 1;
end



class:publish();

return class;