local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="影実_EX1_デルタ", version=2.0, id=2062260});
class:inheritFromEnemy("2062265");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "デルタも狩りする！", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "獲物が、いち、にぃ…たぁくさん！", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ひゃい！　ごめんなさいなのです！", COLOR = Color.red})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end


class:publish();

return class;