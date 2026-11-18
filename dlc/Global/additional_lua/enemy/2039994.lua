local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="東卍SCQグラード", version=1.3, id=2039994});
class:inheritFromEnemy("2039993");

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "なめてんじゃねーぞ！",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "燃焼・氷結・気絶耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "状態異常のときBE出現量アップ"
        })
    }

    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "ビビってるヤツ、いねぇよなぁあ！？",
            COLOR = Color.magenta
        })
    }

    self.END_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.END_MESSAGE1 or "スピードチャレンジ失敗…",
            COLOR = Color.red
        })
    }

end

class:publish();

return class;