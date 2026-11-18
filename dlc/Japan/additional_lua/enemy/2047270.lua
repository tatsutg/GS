local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX皇雅(オウガ)", version=1.3, id=2047270});
class:inheritFromEnemy("2047260");

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    },
    HP10 = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1_N = 1,
    ATTACK2_N = 2,
    ATTACK1_R = 3,
    ATTACK2_R = 4,
    ATTACK1_G = 5,
    ATTACK2_G = 6,
    SKILL1_G = 12,
    SKILL2_N = 9,
    SKILL2_R = 10,
    SKILL2_G = 11,
    SKILL3 = 7,
    SKILL4 = 8
}

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp90(status) end,
            HP = 90,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "魔族からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "炎属性ユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "物理耐性アップ", COLOR = Color.yellow})
    }
    self.HP10_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE1 or "龍鱗が瘴気に…狂気に染まる", COLOR = Color.green})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.hpSkill = 0

    self.saveBP = 0

    self.weatherNum = 1
    self.weather = {
        [1] = "_N",---無
        [2] = "_R",---雷
        [3] = "_G",---風
        [4] = "_B",---雨
    }
    self.weatherLevel = ""
    self.weatherOrbit = nil
    self.wcFLG = false

    self:showMessage(self.START_MESSAGE_LIST)
    return 1
end

function class:hp90(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.weatherLevel = "2"---天候強化
        self.hpSkill = 3---Rモードに変化
        --self.gameUnit:setInvincibleTime(10)
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
    end
end

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4---Gモードに変化
        --self.gameUnit:setInvincibleTime(10)
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        --self.gameUnit:setInvincibleTime(10)
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
    end
end

function class:hp10(status)
    if status == "use3" then
        self.stateName = "FURY"
        self:initSkillWeight({HP10 = 100})
        self:showMessage(self.HP10_MESSAGE_LIST)
    end
end

class:publish();

return class;