local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="デイリーEX_叡樹巨神オルゲス", version=2.4, id=2063584});
class:inheritFromEnemy("2063581");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "応！", COLOR = Color.green})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "これほどか…！", COLOR = Color.green})
    }
end


class:publish();

return class;