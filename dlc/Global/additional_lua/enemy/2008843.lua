local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹ミラ", version=1.3, id=2008843});
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
--ヨミ死亡時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.YOMI_ID = 62

function class:setMessageBoxList()
  self.START_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "桜華一刀流ミラ、参る！",
      COLOR = Color.green,
      DURATION = 5
    }
  }
  self.DEAD_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.DEAD_MESSAGE1 or "サクラ...ごめんなさい...",
      COLOR = Color.green,
      DURATION = 5
    }
  }
  self.DESTROY_YOMI_MESSAGE_LIST = {
    [0] = {
      MESSAGE = self.TEXT.DESTROY_YOMI_MESSAGE1 or "よくもヨミを...！",
      COLOR = Color.green,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.DESTROY_YOMI_MESSAGE2 or "ダメージUP",
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
  event.unit:setSPGainValue(0);
  event.unit:setSkillInvocationWeight(0);
  self.HP_TRIGGERS = {
    [50] = "HP_FLG_50"
  }
  self.gameUnit = event.unit;
  self:setMessageBoxList()
  self:showMessage(self.START_MESSAGE_LIST)

  self.isRage = false
  self.isFalled = false
  self.isOnceSkill = false

  self.hpMarkers = {
    {
      HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
    }
  }
  return 1
end

function class:addSP(unit)  
  unit:addSP(self.spValue);
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  for _,marker in pairs(self.hpMarkers) do
    local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
    if not marker.isUsed and hpPercent < marker.HP then
      marker.isUsed = true
      event.unit:removeHpMarker(marker.MARKER)
    end
  end
  if not megast.Battle:getInstance():isHost() then
    return 1
  end

  self:HPTriggersCheck(event.unit);

  if not self:isBuddyStillAlive(event.unit) and not self.isFalled then
    self.isFalled = true
    self:fallYomi(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
  end
  return 1
end

function class:isBuddyStillAlive(unit)    
  for i=0,7 do
    local target = unit:getTeam():getTeamUnit(i);
    if target ~= nil and target ~= unit and target:getBaseID3() == self.YOMI_ID then
      return true;
    end
  end
  return false;
end

function class:fallYomi(unit)
  self:showMessage(self.DESTROY_YOMI_MESSAGE_LIST)
  self:addBuffs(unit,self.RAGE_BUFF_ARGS)
  unit:addSP(100)
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
  self:deadMessage()
  megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
  return 1
end

function class:deadMessage()
  self:showMessage(self.DEAD_MESSAGE_LIST)
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

  if event.index == 2 then
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

  if self.isFalled and not self.isOnceSkill then
    self.isOnceSkill = true
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
end

function class:getIsHost()
  return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
  self:hpFlg50(self.gameUnit)
  return 1
end

function class:receive4(args)
  self:fallYomi(self.gameUnit)
  return 1
end

function class:receive5(args)
  self:deadMessage()
  return 1
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
-- バフ関係
--===================================================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end


class:publish();

return class;