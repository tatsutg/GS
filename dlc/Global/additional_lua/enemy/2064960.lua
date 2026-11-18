local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_シュナ", version=2.4, id=2064960});
class:inheritFromEnemy("2064965");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL2 = 5,
    SKILL3 = 6
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "参りましょう！", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "願いましょう", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "そんな…", COLOR = Color.yellow})
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