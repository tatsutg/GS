local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="アルマ", version=1.3, id=2005250});
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

class.FIRST_ACTIVE_SKILL = 5
class.RIANA_ID = 216


--------[[特殊行動フラグ]]--------
function class:setHpTriggersList()
  self.HP_TRIGGERS = {
    [0] = {
      tag = "HP_FLG_50",
      action = function (status) self:hpFlg50(status) end,
      timing = 50,
      used = false
    }
  }
end

function class:hpFlg50(status)
  if status == "use" then
    self.isRage = true
  end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
  self.START_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "イッツ・ショータイム！",
      COLOR = Color.green,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル無効",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [2] = {
      MESSAGE = self.TEXT.START_MESSAGE3 or "アルマ無敵",
      COLOR = Color.yellow,
      DURATION = 5
    }
  }

  self.DEAD_MESSAGE_LIST = {
   [0] = {
      MESSAGE = self.TEXT.DEAD_MESSAGE or "時空の彼方にさよーならー！",
      COLOR = Color.green,
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
  -- self.HP_TRIGGERS = {
  --   [50] = "HP_FLG_50"
  -- }
  self.gameUnit = event.unit;
  self:setMessageBoxList()
  self:setHpTriggersList()
  self:showMessage(self.START_MESSAGE_LIST)

  self.isRage = false
  self.isFirstSkillUsed = false
  self.isFirstActiveSkillUsed = false
  event.unit:setInvincibleTime(99999)
  event.unit:setHPBarHeightOffset(10000)
  return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  event.unit:setRange_Min(50)
  event.unit:addSP(100)
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setInvincibleTime(99999)
  if not megast.Battle:getInstance():isHost() then
    return 1
  end

  self:HPTriggersCheck(event.unit);
  if self:buddyUnitCatcher(event.unit,self.RIANA_ID) == nil then
    event.unit:setHP(0)
  end
  return 1
end

function class:buddyUnitCatcher(unit,buddyId)
  for i=0,7 do
    local target = unit:getTeam():getTeamUnit(i);
    if target ~= nil and target ~= unit and target:getBaseID3() == buddyId then
      return target;
    end
  end
  return nil;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
  self:showMessage(self.DEAD_MESSAGE_LIST)
  megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
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
  return 1
end

function class:attackReroll(unit)
  if not self.isFirstSkillUsed then
    return 0
  end

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
  if event.index == 3 and not self.isFirstActiveSkillUsed then
    self.isFirstActiveSkillUsed = true
    event.unit:setActiveSkill(self.FIRST_ACTIVE_SKILL)
  end
  return 1
end

function class:skillReroll(unit)
  local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
  local skillIndex = string.gsub(skillStr,"SKILL","");

  if self.isRage then
    skillIndex = 3
  end

  if not self.isFirstSkillUsed then
    self.isFirstSkillUsed = true
    skillIndex = 3
  end

  unit:takeSkill(tonumber(skillIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
  return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
  self.HP_TRIGGERS[args.arg].action("use")
  return 1
end

function class:receive4(args)
  self:showMessage(self.DEAD_MESSAGE_LIST)
  return 1
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
  if not self:getIsHost() then
    return;
  end

  local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
  local priorityIndex = nil

  for index,trigger in pairs(self.HP_TRIGGERS) do
    if trigger.timing >= hpRate and
      not trigger.used then
      if priorityIndex == nil then
        priorityIndex = index
      end
      priorityIndex = self.HP_TRIGGERS[priorityIndex].timing > trigger.timing and index or priorityIndex
    end
  end
  self:executeTrigger(priorityIndex)
end

function class:executeTrigger(index)
  if index == nil then
    return
  end

  self.HP_TRIGGERS[index].used = true
  self.HP_TRIGGERS[index].action("use")
  megast.Battle:getInstance():sendEventToLua(self.scriptID,3,index)

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