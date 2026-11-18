local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="18章ベルギラス", version=1.3, id=1803003});
class:inheritFromEnemy("1805024");

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "炎・光属性からの被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "装備スキルによる被ダメージアップ"})
    }
    self.HP_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP_MESSAGE1 or "物理・魔法耐性アップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP_MESSAGE2 or "装備スキルによる被ダメージアップ"})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "物理耐性アップ"})
    }
end

class:publish();

return class;