local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="29章_EX1_超ヴァレリー", version=1.3, id=2905020});
class:inheritFromEnemy("2905023");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.cutInSkill = {
    [3] = 1
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "本気で行くよ", COLOR = Color.cyan})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "見せてあげる", COLOR = Color.cyan})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "弱いな…わたし…", COLOR = Color.cyan})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end


class:publish();

return class;