local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_Hard_凶戦士ダラン", version=2.5, id=600000125});
class:inheritFromEnemy("600000128");

---Hard_大型シーリア(enemyID:600000120)の召喚用

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 5,
        startAddSP = 0,
        attackDelay = -1,
        hitStop = 100,
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    --self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    self.setHPFlg = true;
    self.nowHP = event.unit:getCalcHPMAX();
    self.buffID = 600121300;
    self.dmgValFindRaceType1 = 1;  --人族
    self.dmgValFindRaceType2 = 4;  --巨人族
    self.dmgValRate = 0.2;
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    --特定の種族以外からのダメージ軽減
    if enemyUnit:getRaceType() == self.dmgValFindRaceType1 or enemyUnit:getRaceType() == self.dmgValFindRaceType2 then
    else
        event.value = event.value * self.dmgValRate;
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end


class:publish();

return class;