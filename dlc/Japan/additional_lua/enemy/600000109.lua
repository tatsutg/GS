--@additionalEnemy,600000111
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_弱_絶氷竜アエルグラキエス", version=2.0, id=600000109});
class:inheritFromEnemy("600000110");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 10,
        hitStop = 100,
        dmgVal = 0.5,
        deBuffDmgVal = 1.3,
        bossBuffTime = 1,
        unitBuffTime = 1,
        buffVal_2 = 2,
        buffVal_13 = 2,
        buffVal_23 = 5,
        buffVal_59 = -20,
        buffVal_60_1 = 10,
        buffVal_60_2 = 10,
        targetBuffVal_23 = 50,
        buffTime_96_1 = 60,
        buffTime_96_2 = 20,
        startSummon = 1,
        attackSummon = 1,
        skillSummon = 2
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
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.burnBuffFlg = nil
    self.summonUnitID = 600000111
    self.targetIndex = 0
    self.bossTimeBuff = 0
    self.unitTimeBuffTbl = {}
    for i = 0,3 do
        self.unitTimeBuffTbl[i] = 0
    end

    ---自動ヘイトは使わない
    self.targetUnitList = {}
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    --ボス固有の変数
    self.isLockOn = true
    self.neckAngle = 0
    self.shotAngle = 0
    self.isFireEnd = true
    return 1
end



class:publish();

return class;