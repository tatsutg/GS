local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="シズEX2", version=1.3, id=2065465});
class:inheritFromEnemy("2065460");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL5 = 4
}

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "覚悟はできてる？",
            COLOR = Color.red
        })
    }

    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "そんな…もう…",
            COLOR = Color.red
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "また失敗しちゃった…",
            COLOR = Color.red
        })
    }

end

function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 5
    end
end

class:publish();

return class;