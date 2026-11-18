local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="イフリート/超神級/wave2", version=1.9, id=2032610})
class:inheritFromEnemy("2032602") -- 初級

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "庇うキラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼状態の敵へのダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ブレイクをするたびに与ダメージダウン"})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！ボスの与ダメージダウン！"})
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
        {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
    self.hpMarkers[1] = self.gameUnit:addNumHpMarker(0.01)
end

class:publish()
return class
