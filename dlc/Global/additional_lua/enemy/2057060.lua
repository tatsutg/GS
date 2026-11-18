local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ブルージャケット_EX1_ラーク", version=1.3, id=2057060});
class:inheritFromEnemy("2057065");

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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "――斬る", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "炎帝剣四の型、斬火の灯", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "…やるな", COLOR = Color.red})
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