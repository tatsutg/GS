local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_ミーナス", version=2.4, id=2064460});
class:inheritFromEnemy("2064465");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "いいぜ、やったらァ", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "テメーのコブシは『純』じゃねえンだよ！！", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "チッ…もうダメか…", COLOR = Color.red})
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