local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ラビッツ4_EX1_アンリエッタ", version=2.5, id=2075160});
class:inheritFromEnemy("2075170");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "さぁ、行きましょうか", COLOR = Color.cyan})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "覇王の剣よ、道を切り開け！", COLOR = Color.cyan})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "私の予測を超えるなんて…やるわね！", COLOR = Color.cyan})
    }
end


class:publish();

return class;