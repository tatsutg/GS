local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ２中編_EX1_水着美遊", version=2.0, id=2059760});
class:inheritFromEnemy("2059765");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.cutInSkill = {
    [3] = 0
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "イリヤとの夏、邪魔はさせない", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クラスカード『バーサーカー』――", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "イ…イリヤ、ごめん…ね…", COLOR = Color.red})
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