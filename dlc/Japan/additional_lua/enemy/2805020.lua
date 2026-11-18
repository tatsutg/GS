local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="28章_EX1_超ハルト", version=1.3, id=2805020});
class:inheritFromEnemy("2805023");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.cutInSkill = {
    [3] = 1
}


function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 3
    end
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "行くよ――", COLOR = Color.magenta})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "この身を満たせ", COLOR = Color.magenta})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ふざっ…けるな……", COLOR = Color.magenta})
    }
end


class:publish();

return class;