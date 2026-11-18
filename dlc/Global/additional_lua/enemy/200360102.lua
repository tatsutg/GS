local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レグルス", version=1.3, id=2005434});
class:inheritFromUnit("unitBossBase")

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
  ATTACK1 = 50,
  ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
  SKILL2 = 100
}

class.ACTIVE_SKILLS = {
  ATTACK1 = 1,
  SKILL1 = 2,
  SKILL2 = 3,
  SKILL3 = 4
}

function class:setMessageBoxList()
  self.START_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "貴様の実力、しかと見届けん！",
      COLOR = Color.magenta,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカル耐性",
      COLOR = Color.yellow,
      DURATION = 5
    }
  }
  self.FINISH_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.FINISH_MESSAGE1 or "本気をだそう！！",
      COLOR = Color.magenta,
      DURATION = 5
    }
  }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.fromHost = false;
  self.gameUnit = nil;
  self.spValue = 20;
  self.attackCheckFlg = false;
  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  event.unit:setSPGainValue(0);
  event.unit:setSkillInvocationWeight(0);  
  self.HP_TRIGGERS = {
      [10] = "HP_FLG_10"
  }
  self.gameUnit = event.unit;
  self:setMessageBoxList()
  self:showMessage(self.START_MESSAGE_LIST)

  self.isFirstTime = true
  self.hitStop = 0.5
  return 1
end

function class:addSP(unit)  
  unit:addSP(self.spValue);
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  self.skillCheckFlg = true
  event.unit:takeSkill(3)
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setReduceHitStop(2,self.hitStop)
  self:HPTriggersCheck(event.unit);
  return 1
end

---------------------------------------------------------------------------------
-- ゴジラ合わせでブレイクしないように
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
 	return 0;
end

function class:dead(this , unit)
  return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
  if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
    self.attackCheckFlg = true;
    return self:attackReroll(event.unit);
  end
  self.attackCheckFlg = false;
  if not megast.Battle:getInstance():isHost() and not self.fromHost then
    event.unit:takeIdle();
    return 0;
  end
  self.fromHost = false;
  self:addSP(event.unit);
  self:attackActiveSkillSetter(event.unit,event.index);
  return 1
end

function class:attackReroll(unit)
  local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
  local attackIndex = string.gsub(attackStr,"ATTACK","");
  if tonumber(attackIndex) == 1 then
      unit:takeAttack(tonumber(attackIndex));
  else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
  end
  megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
  return 0;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
    self.skillCheckFlg = true;
    return self:skillReroll(event.unit);
  end

  if event.index == 3 and not self.skillCheckFlg2 then
    self.skillCheckFlg2 = true;
    event.unit:takeSkillWithCutin(3,1);
    return 0;
  end

  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  self.fromHost = false;
  self:skillActiveSkillSetter(event.unit,event.index);
  if event.index == 3 and self.isFirstTime then
    self.isFirstTime = false
    event.unit:setActiveSkill(5)
  end
  return 1
end

function class:skillReroll(unit)
  local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
  local skillIndex = string.gsub(skillStr,"SKILL","");


  unit:takeSkill(tonumber(skillIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
  return 0;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
  if not self:getIsHost() then
    return;
  end
  
  local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
  
  for i,v in pairs(self.HP_TRIGGERS) do
    if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
      self:excuteTrigger(unit,self.HP_TRIGGERS[i]);
      self.HP_TRIGGERS[i] = nil;
    end
  end
end

function class:excuteTrigger(unit,trigger)
  if trigger == "HP_FLG_10" then
    self:hpFlg10(unit);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
  end
end

function class:hpFlg10(unit)
  if unit.m_breaktime <= 0 then
    self:showMessage(self.FINISH_MESSAGE_LIST)
    self.skillCheckFlg = true
    unit:takeSkill(3)
  end
end

function class:getIsHost()
  return megast.Battle:getInstance():isHost();
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
  if index == nil then 
    self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
    return
  end
  self:execShowMessage(messageBoxList[index])
end

function class:showMessageRange(messageBoxList,start,finish)
  for i = start,finish do
    self:execShowMessage(messageBoxList[i])
  end
end

function class:execShowMessage(messageBox)
  summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end



class:publish();

return class;