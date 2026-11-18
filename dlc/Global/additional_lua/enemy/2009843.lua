local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇ゼイオルグ", version=1.3, id=2009843});
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

class.ZENON_ID = 121
class.LILY_ID = 65

--------[[特殊行動フラグ]]--------
function class:setHpTriggersList()
   self.HP_FLG_1 = 0
   self.DEAD_ZENON = 1
   self.DEAD_LILY = 2
   self.TRIGGERS = {
      [self.HP_FLG_1] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [self.DEAD_ZENON] = {
         tag = "DEAD_ZENON",
         action = function (status) self:deadZenon(status) end,
         used = false
      },
      [self.DEAD_LILY] = {
         tag = "DEAD_LILY",
         action = function (status) self:deadLily(status) end,
         used = false
      }
   }
end

function class:hpFlg50(status)
   if status == "use" then
      self.isRage = true
      self.gameUnit:addSP(100)
      self:showMessage(self.RAGE_MESSAGE_LIST)
   end
end

function class:deadZenon(status)
   if status == "use" then
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[self.OUGI_UP])
      self:showMessage(self.DEAD_ZENON_MESSAGE_LIST)
   end
end

function class:deadLily(status)
   if status == "use" then
      self.spValue = 40
      self:showMessage(self.DEAD_LILY_MESSAGE_LIST)
   end
end

----------[[バフ]]----------
function class:setBuffBoxList()
   self.OUGI_UP = 0
   self.BUFF_BOX_LIST = {
      [self.OUGI_UP] = {
         ID = 20098431,
         BUFF_ID = 17,     --ダメージUP
         VALUE = 25,        --効果量
         DURATION = 999999,
         ICON = 26
      }
   }
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "稽古か？手加減はできんぞ...！",
         COLOR = Color.magenta,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "闇・光以外へのダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "回避率アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.DEAD_ZENON_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.DEAD_ZENON_MESSAGE or "ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.DEAD_LILY_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.DEAD_LILY_MESSAGE or "奥義ゲージ増加速度アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.RAGE_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE or "まだ、半分も力を出しておらん...！！",
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
   self.gameUnit = event.unit;
   self:setBuffBoxList()
   self:setMessageBoxList()
   self:setHpTriggersList()
   self:showMessage(self.START_MESSAGE_LIST)
   self.isRage = false
   self.isRageSkill = false
   self.hpMarkers = {
      {
         HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
      }
   }
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

function class:addSP(unit)  
   unit:addSP(self.spValue);
   return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if not megast.Battle:getInstance():isHost() then
      return 1
   end

   self:HPTriggersCheck(event.unit);
   
   if self:buddyUnitCatcher(event.unit,self.ZENON_ID) == nil and not self.TRIGGERS[self.DEAD_ZENON].used then
      self:execTrigger(self.DEAD_ZENON)
   end
   if self:buddyUnitCatcher(event.unit,self.LILY_ID) == nil and not self.TRIGGERS[self.DEAD_LILY].used then
      self:execTrigger(self.DEAD_LILY)
   end

   for _,marker in pairs(self.hpMarkers) do
      local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
      if not marker.isUsed and hpPercent < marker.HP then
         marker.isUsed = true
         event.unit:removeHpMarker(marker.MARKER)
      end
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
   if event.index == 3 and not self.isRageSkill then
      self.isRageSkill = true
      event.unit:setActiveSkill(5)
   end
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use")
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
  
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         if trigger.timing >= hpRate and not trigger.used then
            if priorityIndex == nil then 
               priorityIndex = index 
            end
            priorityIndex = self.TRIGGERS[priorityIndex].timing > trigger.timing and index or priorityIndex
         end
      end
   end
   self:execTrigger(priorityIndex)
end

function class:execTrigger(index)
  if index == nil or table.maxn(self.TRIGGERS) < index then
    return
  end

  self.TRIGGERS[index].used = true
  self.TRIGGERS[index].action("use")
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

--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

   if buffBox.SCRIPT_ID ~= nil then
      buff:setScriptID(buffBox.SCRIPT_ID);
   end
   if buffBox.SCRIPTVALUE1 ~= nil then
      buff:setValue1(buffBox.SCRIPTVALUE1);
   end
end


class:publish();

return class;
