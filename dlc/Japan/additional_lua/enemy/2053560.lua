local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_イビル・ポーラ", version=1.3, id=2053560});
class:inheritFromEnemy("2053565");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "さぁ、こっちにいらっしゃい", COLOR = Color.green})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "本当の私、あなたにわかるかしら？", COLOR = Color.green})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ウソ……でしょ……", COLOR = Color.green})
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