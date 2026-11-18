local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="36章_EX1_デューク", version=2.4, id=3605020});
class:inheritFromEnemy("3605023");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "覚悟はいいな", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射耐性", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "本気でいくか…", COLOR = Color.magenta})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "無念…だ……", COLOR = Color.magenta})
    }
end


class:publish();

return class;