local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡11層_Normal_真魔翼従ヴァルザンデス", version=2.6, id=2064000});
class:inheritFromEnemy("2064005");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "破滅の咆哮：%dの固定ダメージ", COLOR = Color.yellow})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "シャドウライトニングの構え：魔法ダメージで解除", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "シャドウライトニングの構え：魔法ダメージで解除", COLOR = Color.yellow})
    }
    self.EX_GAUGE_BROKEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE1 or "構え解除成功！", COLOR = Color.red})
    }
end


class:publish();

return class;