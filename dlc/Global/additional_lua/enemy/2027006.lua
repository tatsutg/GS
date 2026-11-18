local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="ラグシェルムX／超神級／Wave1", version=1.9, id=2027006})
class:inheritFromEnemy("2027005") -- 超級

----------[[ メッセージ ]]----------
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "最大HPが高いユニットへのダメージUP",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "闇属性耐性・光キラー・反射耐性",
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
        },
        {
            MESSAGE = self.TEXT.OGI_MESSAGE2 or "ダメージ無効化無効",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.DEAD_MESSAGE_LIST = {

    }
end

class:publish()
return class
