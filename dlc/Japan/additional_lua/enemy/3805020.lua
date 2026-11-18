local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="38章_EX1_超ヴァレリー", version=2.8, id=3805020});
class:inheritFromEnemy("3805023");

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "本気で行くよ", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "見せてあげる", COLOR = Color.cyan})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "うあああああああ！！", COLOR = Color.cyan})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 3
        -- self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        -- self.gameUnit:setInvincibleTime(10)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end


class:publish()

return class