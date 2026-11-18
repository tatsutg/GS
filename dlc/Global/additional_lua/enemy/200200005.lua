local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="巨大ダキュオン２", version=1.7, id=200200005})
enemy:inheritFromEnemy(200200004)

function enemy:startWave(event)
    Utility.messageByEnemy(self.TEXT.START_MESSAGE, 5, summoner.Color.magenta)
    return 1
end

enemy:publish()
return enemy
