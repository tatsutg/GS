local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="16章4-5_NORMAL_闇ハルト", version=1.3, id=1604016});
class:inheritFromEnemy("1604015");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = 30,
            DURATION = 99999,
            ICON = 26
        }
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST = {
        ID = 20336541,
        BUFF_ID = 113, ---状態異常耐性(状態異常回避率)
        VALUE = 999999,
        DURATION = 999999,
        ICON = 67
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST2 = {
        ID = 20336541,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 0,
        ICON = 0
    }
    self.ANTI_PROTECTION_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 10,
            ICON = 79
        },
        [2] = {
            ID = 0,
            BUFF_ID = 21,
            VALUE = 25,
            DURATION = 10,
            ICON = 139
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "覚悟はいいかい？",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "魔法耐性"
        })
    }
    self.ANTI_PROTECTION_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.ANTI_PROTECTION_MESSAGE1 or "庇っている者を気絶＆被ダメージアップ",
            COLOR = Color.red
        })
    }
    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "これが痛みだ",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "奥義上昇量・与ダメージアップ"
        })
    }
    self.HP1_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP1_MESSAGE1 or "ここで行き止まりだ",
            COLOR = Color.magenta
        })
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ボクは、認めない……！",
            COLOR = Color.magenta
        })
    }
end


class:publish();

return class;