local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ラキ", version=1.3, id=2008243});
class:inheritFromUnit("unitBossBase");
  
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

class.GOBU_ID = 16

function class:setBuffBoxList()
  self.BUFF_BOX_LIST = {
    [0] = {
      ID = 40075,
      BUFF_ID = 17,      --ダメージアップ
      VALUE = 20,        --効果量
      DURATION = 9999999,
      ICON_ID = 26,
      EFFECT = 50009
    },
    [1] = {
      ID = 40076,
      BUFF_ID = 15,         --防御ダウン
      VALUE = -25,        --効果量
      DURATION = 9999999,
      ICON_ID = 6
    }
  }
end

function class:setMessageBoxList()
  self.START_MESSAGES = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "闇属性耐性",
      COLOR = Color.yellow,
      DURATION = 5
    }
  }

  self.FALL_GOBU_MESSAGES = {
    [0] = {
      MESSAGE = self.TEXT.FALL_GOBU_MESSAGE1 or "そんな...ゴブ...",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.FALL_GOBU_MESSAGE2 or "与ダメージUP",
      COLOR = Color.red,
      DURATION = 5
    },
    [2] = {
      MESSAGE = self.TEXT.FALL_GOBU_MESSAGE3 or "防御力DOWN",
      COLOR = Color.yellow,
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
  self.HP_TRIGGERS = {
    [50] = "HP_FLG_50"
  }

  self.isFalled = false;
  self:setMessageBoxList()
  self:setBuffBoxList()
  self.gameUnit = event.unit;
  event.unit:setSPGainValue(0);
  return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  -- self:showMessage(self.START_MESSAGES)
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if not megast.Battle:getInstance():isHost() then
    return 1
  end

  -- self:HPTriggersCheck(event.unit)
  -- if not self:isBuddyStillAlive(event.unit) and not self.isFalled then
  --   self.isFalled = true
  --   self:fallGobu(event.unit)
  --   megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
  -- end
  return 1
end

function class:isBuddyStillAlive(unit)    
  for i=0,7 do
    local target = unit:getTeam():getTeamUnit(i);
    if target ~= nil and target ~= unit and target:getBaseID3() == self.GOBU_ID then
      return true;
    end
  end
  return false;
end

function class:fallGobu(unit)
  self:showMessage(self.FALL_GOBU_MESSAGES)
  self:execAddCondition(unit,self.BUFF_BOX_LIST[0])
  self:execAddCondition(unit,self.BUFF_BOX_LIST[1])
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

  -- if self.isRage then 
  --   skillIndex = 3
  -- end

  unit:takeSkill(tonumber(skillIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
  return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
  self:hp_50(self.gameUnit)
  return 1
end

function class:receive4(args)
  self:fallGobu(self.gameUnit)
  return 1
end


--===================================================================================================================
--HPトリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
  if not self:getIsHost() then
    return
  end

  local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

  for i,v in pairs(self.HP_TRIGGERS) do
    if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
      if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
        self.HP_TRIGGERS[i] = nil;
      end
    end
  end
end

function class:excuteTrigger(unit,trigger)
  if trigger == "HP_FLG_50" then
    self:hp_50(unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    return true
  end
  return false
end

function class:hp_50(unit)
  self.isRage = true
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

--===================================================================================================================
--バフ
--===================================================================================================================
function class:execAddCondition(unit,buffBox)
  if buffBox.EFFECT_ID == nil then
    unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON_ID)
  else
    unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON_ID,buffBox.EFFECT_ID)
  end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;