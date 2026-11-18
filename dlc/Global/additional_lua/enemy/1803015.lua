local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="18章彩忍ロゼッタ", version=1.3, id=1803015});
class:inheritFromEnemy("1803017");

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "ちょっぴり大人になったロゼッタさん、可憐に参上！",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "HP50%以下のユニットに対してのクリティカル率アップ"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "暗闇状態のとき被ダメージアップ"
        }),
        [5] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE5 or "水属性キラー"
        })
    }

    self.HP80_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "力ある言葉よ、薙ぎ払え",
            COLOR = Color.green
        })
    }

    self.HP60_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "魂天の紋章よ、星の如く煌け",
            COLOR = Color.green
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "我らが王に誓う",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "紅き血をもって大義をなさん",
            COLOR = Color.green
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE3 or "奥義上昇量アップ・物理ダメージ軽減"
        })
    }

    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "もっと深く――血の深淵へ",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量・クリティカル耐性アップ"
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "レオーネ、みんな……ごめん……",
            COLOR = Color.green
        })
    }

    self.SKILL2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "最大HP%d％の割合ダメージ"
        })
    }

    self.SKILL3_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "ダメージ無効化解除"
        })
    }

end

class:publish();

return class;