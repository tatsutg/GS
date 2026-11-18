local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="バドル", version=1.3, id=2009405});
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

class.SLICED_DAMAGE_SIZE = 0.1

function class:setMessageBoxList()
  self.START_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "ブレイク耐性UP",
      COLOR = Color.yellow,
      DURATION = 7
    },
    [1] = {
      MESSAGE = self.TEXT.START_MESSAGE2 or "光・樹属性キラー",
      COLOR = Color.yellow,
      DURATION = 7
    },
    [2] = {
      MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼時クリティカル",
      COLOR = Color.yellow,
      DURATION = 7
    }
  }

  self.RAGE_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE1 or "力を解放する...！",
      COLOR = Color.red,
      DURATION = 7
    },
    [1] = {
      MESSAGE = self.TEXT.RAGE_MESSAGE2 or "行動速度・ダメージUP",
      COLOR = Color.yellow,
      DURATION = 7
    }
  }

  self.BREAK_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.BREAK_MESSAGE or "クリティカル被ダメージUP",
      COLOR = Color.yellow,
      DURATION = 7
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
    [50] = "HP_FLG_50"
  }
  self.gameUnit = event.unit;
  self.hpMarkers = {}
  for index,trigger in pairs(self.HP_TRIGGERS) do
    self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
  end
  self:setMessageBoxList()
  self:showMessage(self.START_MESSAGE_LIST)

  self.isBreak = false
  self.isRage = false
  self.isBurn = false
  self.isFirstSkill = false
  self.hitStop = 1

  return 1
end

function class:addSP(unit)
  unit:addSP(self.spValue);
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
  if self.isFirstSkill then
    event.unit:setReduceHitStop(2,0)
  end
  return 1
end
---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if not megast.Battle:getInstance():isHost() then
    return 1
  end

  self:HPTriggersCheck(event.unit);
  return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  if not self.isBreak then
    return event.value * self.SLICED_DAMAGE_SIZE
  end
  return event.value
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
  if not self.isBreak then
    self.isBreak = true
    self:showMessage(self.BREAK_MESSAGE_LIST)
  end
  return 1
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
  self:attackActiveSkillSetter(event.unit,event.index);
  self:addSP(event.unit);
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

  if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
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
  return 1
end

function class:skillReroll(unit)
  local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
  local skillIndex = string.gsub(skillStr,"SKILL","");

  if self.isRage then 
    skillIndex = 3
  end

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
      if self.hpMarkers[i] ~= nil then
        self.gameUnit:removeHpMarker(self.hpMarkers[i])
      end
    end
  end
end

function class:excuteTrigger(unit,trigger)
  if trigger == "HP_FLG_50" then
    self:hpFlg50(unit);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
  end
end

function class:hpFlg50(unit)
  self.isRage = true
  self:showMessage(self.RAGE_MESSAGE_LIST)
end

function class:getIsHost()
  return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
  self:hpFlg50(self.gameUnit);
  return 1;
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