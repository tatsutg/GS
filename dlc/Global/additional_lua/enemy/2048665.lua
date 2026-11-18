local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ中編_EX2_衛宮士郎", version=1.3, id=2048665});
class:inheritFromEnemy("2048660");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "覚悟はいいか、正義の味方",
            COLOR = Color.cyan
        })
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "消し飛ばしてやる",
            COLOR = Color.cyan
        })
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "こんな…ところで…",
            COLOR = Color.cyan
        })
    }
end


class:publish();

return class;