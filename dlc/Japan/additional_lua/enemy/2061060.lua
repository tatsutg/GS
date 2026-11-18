local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_水着シーリア", version=2.0, id=2061060});
class:inheritFromEnemy("2061065");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "いつでもどうぞ", COLOR = Color.magenta})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "いざ、理想郷へ", COLOR = Color.magenta})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "良い汗をかきました", COLOR = Color.magenta})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 3
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end


class:publish();

return class;