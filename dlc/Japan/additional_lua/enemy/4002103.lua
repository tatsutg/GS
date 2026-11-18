local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="SX-602型", version=1.3, id=4002103});
class:inheritFromEnemy("4002101");

class.myID = 4002103

function class:setMessageBoxList()
    self.SUMMON_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "SX-602型Limitedが加勢した",
            COLOR = Color.magenta
        })
    }
end

class:publish();

return class;