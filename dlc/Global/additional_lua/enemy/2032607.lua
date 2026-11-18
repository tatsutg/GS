local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="ジンガルム/超級/wave1", version=1.9, id=2032607})
class:inheritFromEnemy("2032601") -- 初級

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・魔法・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "樹属性キラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "氷結状態のとき防御力ダウン"})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "与ダメージ・奥義ゲージ上昇量アップ"})
    }
end

class:publish()
return class
