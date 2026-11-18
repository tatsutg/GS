local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="26章/運命を超えしイスリーダ皇帝normal", version=1.3, id=2604003});
class:inheritFromEnemy("2604013");

function class:setMessageBoxList()
    self.TRUE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_MESSAGE1 or "レイアス。さぁ、剣を取れ。", COLOR = Color.white})
    }
    self.FALSE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_MESSAGE1 or "世界はこのイスリーダ皇帝が護ろう。", COLOR = Color.white})
    }
    self.DEAD_TRUE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_TRUE_MESSAGE1 or "やはり、最後に立ちはだかるのはキミか。", COLOR = Color.white})
    }
    self.DEAD_FALSE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_FALSE_MESSAGE1 or "痛みは受け入れよう。", COLOR = Color.white})
    }
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.ATTACK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.ATTACK_MESSAGE1 or "スカイライト：神族を気絶", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.ATTACK_MESSAGE2 or "グランヴィス：人族を気絶", COLOR = Color.red}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.ATTACK_MESSAGE3 or "ダークブリンガー：魔族を気絶", COLOR = Color.red})
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "新世界の鼓動が聴こえる。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE2 or "魔法耐性アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "大いなる意思よ。この身に宿れ。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量・防御力アップ", COLOR = Color.yellow})
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "ニルシャナルの魔眼。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "ようやく馴染んできたよ。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE3 or "回避率アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "僕は運命を超える。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "このルーンマスターと共に。", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "HP自然回復・奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE4 or "鉄壁状態：ブレイクで解除", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク耐性ダウン", COLOR = Color.yellow})
    }
    self.BARRIER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BARRIER_MESSAGE1 or "ブレイクで鉄壁状態解除！", COLOR = Color.red})
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:setStunTime()
    self.stunTime = 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.isProtagonist then
        self:showMessage(self.DEAD_TRUE_MESSAGE_LIST)
    else
        self:showMessage(self.DEAD_FALSE_MESSAGE_LIST)
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

class:publish();

return class;