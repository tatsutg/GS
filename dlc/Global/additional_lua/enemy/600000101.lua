local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_蒼凰フレイダル(弱)", version=1.3, id=600000101});
class:inheritFromEnemy("600000102");


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 6010201,
            BUFF_ID = 53,  --毒耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 59,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010202,
            BUFF_ID = 56,  --暗闇耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010203,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 66,
            COUNT = 0,
            MAX = 10
        }
    }
    self.BUFF_LIST2 = {
        [1] = {
            ID = 6010204,
            BUFF_ID = 102,  --毒回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010205,
            BUFF_ID = 105,  --暗闇回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010206,
            BUFF_ID = 109,  --燃焼回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        }
    }
    self.FRY_BUFF_LIST = {
        [1] = {
            ID = 6010207,
            BUFF_ID = 31,  --回避率UP
            VALUE = 30,
            DURATION = 999999,
            ICON = 16
        },
        [2] = {
            ID = 6010207,
            BUFF_ID = 0,  --回避率UP
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 6010208,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 6010209,
            BUFF_ID = 59,  --氷結耐性
            VALUE = -20,
            DURATION = 999999,
            ICON = 75,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010210,
            BUFF_ID = 108,  --氷結回避率
            VALUE = -20,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010211,
            BUFF_ID = 17,  --与ダメ
            VALUE = 20,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        }
    }
    self.TARGET_SKIL_BUFF_LIST = {
        [1] = {
            ID = 6010212,
            BUFF_ID = 96,  --氷結
            VALUE = 100,
            DURATION = 60,
            ICON = 86
        }
    }
    ---ターゲットギミック
    self.TARGET_BUFF_LIST1 = {
        ID = 6010220,
        BUFF_ID = 21,---被ダメージUP
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 6010220,
        BUFF_ID = 0,---被ダメージUP
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "飛行状態：回避率アップ、被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "飛行状態：毒・燃焼・暗闇状態で解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット・ターゲットへのダメージアップ", COLOR = Color.yellow})
    }
    self.STAND_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE1 or "毒で飛行状態解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE2 or "暗闇で飛行状態解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE3 or "燃焼で飛行状態解除成功！", COLOR = Color.red})
    }
    self.FRY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE1 or "毒耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE2 or "暗闇耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE3 or "燃焼耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE4 or "飛行状態：回避率アップ、被ダメージ軽減", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ターゲットを氷結", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(7);---アタックディレイ
    event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({FLY = 100})
    self:initSkillWeight({FLY = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.windUnit = nil
    self.isWind = false
    self.auraUnit = nil

    self.isFlying = true
    self.attack6Flg = false
    self.deBuffFlg = 0
    self.targetIndex = 0
    self.fryDamageRate = 0.5
    self.fryAddSP = 30
    self.standAddSP = 0
    self.fryAttackDelay = 7
    self.standAttackDelay = 10

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end


class:publish();

return class;