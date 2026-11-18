local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX2皇雅(オウガ)", version=1.3, id=2047265});
class:inheritFromEnemy("2047260");

class.ACTIVE_SKILLS = {
    ATTACK1_N = 1,
    ATTACK2_N = 2,
    ATTACK1_B = 3,
    ATTACK2_B = 4,
    SKILL2_N = 6,
    SKILL2_B = 7,
    SKILL5 = 5
}

function class:setMessageBoxList()
    self.WEATHER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_MESSAGE1 or "フィールド効果変化"})
    }
    self.WEATHER_TYPE_MESSAGE_LIST = {
        [1] = {
            self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_TYPE_MESSAGE1_1 or "炎雷：ユニットの最大HP5%DOWN", COLOR = Color.red})
        },
        [3] = {
            self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_TYPE_MESSAGE3_1 or "蝕雨:ユニットの防御力15%ダウン", COLOR = Color.cyan})
        },
        [4] = {
            self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_TYPE_MESSAGE4_1 or "炎雷：ユニットの最大HP・攻撃力10%ダウン", COLOR = Color.red})
        },
        [5] = {
            self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_TYPE_MESSAGE5_1 or "迅風：ユニットの命中率15%ダウン", COLOR = Color.green}),
            self:setMessageInfo({MESSAGE = self.TEXT.WEATHER_TYPE_MESSAGE5_2 or "迅風：炎属性以外のユニットのダメージ70%ダウン", COLOR = Color.green})
        }
    }
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 5---Bモードに変化
        --self.gameUnit:setInvincibleTime(10)
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
    end
end

class:publish();

return class;