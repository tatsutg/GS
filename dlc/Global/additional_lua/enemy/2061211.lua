local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族遺跡_12層_NORMAL_静聖神パルラミシア", version=2.8, id=2061211});
class:inheritFromEnemy("2061216");


function class:setBuffBoxList()
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイク中以外被ダメージ耐性", COLOR = Color.yellow}),
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE2 or "被ダメージ耐性：解除", COLOR = Color.red}),
    }
    self.BREAK_RECOVERY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_RECOVERY_MESSAGE1 or "ブレイク中以外被ダメージ耐性", COLOR = Color.yellow}),
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 0,
        attackDelay = 4,
        hitStop = 100,
        breakDmgVal = 0.2,
    })
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.hpSkill = 0;
    self.saveBP = 0;

    self.breakFlg = false;
    self.hpSkillFLG = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);

    --ユニット固有ギミック
    self.myUnit = event.unit
    self.isTwice = false
    self.isCounterSuccess = false
    self.isCounter = false
    self.isDone = false
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    --ブレイクから復帰した時のinfo
    if self.breakFlg and not event.unit:isBreak() then
        self.breakFlg = false;
        self:showMessage(self.BREAK_RECOVERY_MESSAGE_LIST);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    --ユニット固有
    if self.isCounter and self:isControll(event.unit) then
        self.isCounter = false
        self.isCounterSuccess = true
        self:counterImpl(event.unit)
    end

    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    if not event.unit:isBreak() then
        event.value = event.value * self.GD.breakDmgVal;
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

function class:receive4(args)
    return 1
end


class:publish();

return class;