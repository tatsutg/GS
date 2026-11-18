local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="デイリーEX_焔獄巨神ゾルダス", version=2.4, id=2063583});
class:inheritFromEnemy("2063581");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "征くぞ、兄弟！", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ガハハ！　やりおる！！", COLOR = Color.red})
    }
end


class:publish();

return class;