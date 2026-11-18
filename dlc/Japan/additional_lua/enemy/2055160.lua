local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_マーレット", version=1.3, id=2055160});
class:inheritFromEnemy("2055165");

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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "準備はよろしくて？", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "サービスですわ♪", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "潮時ですわね", COLOR = Color.yellow})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 3
    end
end


class:publish();

return class;