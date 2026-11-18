--@additionalEnemy,2056102,2056101
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_デグルマグナ(弱)", version=1.3, id=600000099});
class:inheritFromEnemy("600000100");

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 600001001,
            BUFF_ID = 17,
            VALUE = 20,
            DURATION = 99999,
            ICON = 26,
            MAX = 10
        },
        [2] = {
            ID = 600001002,
            BUFF_ID = 23,---クリティカル耐性
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 600001003,
            BUFF_ID = 208,---猛炎(上位燃焼)
            VALUE = 300,
            DURATION = 99999,
            ICON = 308,
            SCRIPT = {
                SCRIPT_ID = 602,
                VALUE1 = 1,
                VALUE2 = 4
            }
        }
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
    event.unit:setAttackDelay(8);---アタックディレイ
    event.unit:addSP(60)---戦闘開始時の奥義ゲージ量
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
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.hpSkill = 0

    self.saveBP = 0

    self.infoFLG = false

    self.saveTeamCount = 0

    self.summonEnemy = 2056101

    ---デグルマグナ用
    self.isLockOn = true
    self.neckAngle = 0
    self.shotAngle = 0
    self.isFireEnd = true
    self.fireSwitch = 1
    return 1
end

class:publish();

return class;