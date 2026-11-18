local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_葬魂神オルデウス（弱）", version=2.0, id=600000107});
class:inheritFromEnemy("600000108");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "物理回避", COLOR = Color.yellow})
    }
    self.SCULL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SCULL_MESSAGE1 or "亡霊が冒険者たちに襲いかかる！", COLOR = Color.red})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "状態異常ユニットの奥義ゲージダウン", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "に", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE2 or "の効果", COLOR = Color.red})
    }
    self.BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE1 or "燃焼", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE2 or "毒", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE3 or "病気", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 9,
        hitStop = 100,
        buffValue_17_1 = 0.001,
        buffValue_17_2 = 0.3,
        buffValue_97 = 5000,
        buffValue_90 = 5000,
        buffValue_94 = 45,
        buffTime1 = 20,
        buffTime2 = 5,
        orbitHP = 300000,
        orbitBuffValue = -50,
        downBPValue = 50
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.strongBossFlg = false  --弱はfalse
    self.skill2Flg = false
    self.skill2Count = 0
    self.skill2BuffTime = 0
    self.battleTime = 0
    self.timeValue = 0
    self.buffCount = 0
    self.infoTbl = {}
    self:setBuffBoxList()

    --葬魂神オルデウスの共有ギミック
    self.bullets = {}
    self.bulletInfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1
            }
        end
    }
    return 1
end


class:publish();

return class;