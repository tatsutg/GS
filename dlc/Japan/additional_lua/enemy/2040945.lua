local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="BRS_Q10_CODE XTF:ERASER", version=1.3, id=2040945});
class:inheritFromEnemy("2040960");

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
    }
end

class:publish();

return class;