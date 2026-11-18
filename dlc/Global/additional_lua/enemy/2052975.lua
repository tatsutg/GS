local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ハロウィンイベント_EXデイリー_ハロウィンフォルテ", version=1.3, id=2052975});
class:inheritFromEnemy("2052965"); --EX2

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "トリック、準備だ！", COLOR = Color.magenta})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "これにて終幕だ", COLOR = Color.magenta})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "やはりこの体では…", COLOR = Color.magenta})
    }
end

class:publish();

return class;