local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX水ロゼッタ", version=1.3, id=1803014});
class:inheritFromEnemy("1803016");

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "天才魔術師ロゼッタちゃん参上！",
            COLOR = Color.cyan
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "HP50%以上のユニットに対してのクリティカル率アップ",
            COLOR = Color.yellow
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "気絶状態のとき被ダメージアップ",
            COLOR = Color.yellow
        })
    }

    self.HP80_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "本気でいくよー！",
            COLOR = Color.cyan
        })
    }

    self.HP60_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "もう怒った！",
            COLOR = Color.cyan
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "我らが王に誓う",
            COLOR = Color.cyan
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "紅き血をもって大義をなさん",
            COLOR = Color.cyan
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE3 or "奥義上昇量アップ・魔法ダメージ軽減",
            COLOR = Color.yellow
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "そんなぁ……",
            COLOR = Color.cyan
        })
    }
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isAura then
        local attribute = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            event.value = self:adjustHpFlg(event.unit,event.value)
            return event.value
        end
        event.value = event.value * 0.5
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

class:publish();

return class;