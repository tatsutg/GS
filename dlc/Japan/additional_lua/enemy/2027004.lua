local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="ラグシェルムX／上級", version=1.9, id=2027004})
class:inheritFromEnemy("2027003") -- 中級

----------[[ メッセージ ]]----------
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "最大HPが高いユニットへのダメージUP",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "闇属性耐性・反射耐性",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE1 or "祈れ…懺悔ノ時間ダ",
            COLOR = Color.magenta,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE2 or "HPの高い者をホールド",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE3 or "一定ダメージを与えると解除",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_BREAK_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_BREAK_MESSAGE1 or "何ぃいィイイ！？",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
    self.OGI_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.OGI_MESSAGE1 or "消え失セロォォオオオ！！",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
    self.DEAD_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "消えヌ…我ガ怒りハ…決し…テ……",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
end

class:publish()
return class
