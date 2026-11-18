local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="19章ファフニール", version=1.3, id=1904013});
class:inheritFromEnemy("1904015");

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "ファフニール：クリティカルダメージ無効"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "ファフニール：状態異常のとき被ダメージ・BE量アップ"
        })
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
    event.unit:setAttackDelay(10);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.waves = 0

    self.isTarget = false
    self.maxFriends = 0
    self.nowFriends = 0

    self.myID = 1904013

    self.skill2FLG = false

    self.gameUnit:setInvincibleTime(10)
    return 1
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [0] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        },
        [1] = {
            ID = 1003535111,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [2] = {
            ID = 1003535112,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 97,
            VALUE = 1000,
            DURATION = 10,
            ICON = 87
        },
        [4] = {
            ID = 1904015,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            EFFECT = 1
        },
        [5] = {
            ID = 19040151,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

class:publish();

return class;