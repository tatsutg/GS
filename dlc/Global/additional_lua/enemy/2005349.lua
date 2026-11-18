local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="アルス", version=1.3, id=2005349});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
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

class.VOGE_ID = 194

--------[[特殊行動フラグ]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 0
   self.DEAD_VOGE = 1

   self.TRIGGERS = {
      [self.HP_50] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [self.DEAD_VOGE] = {
         tag = "DEAD_VOGE",
         action = function (status) self:deadVoge(status) end,
         used = false
      }
   }
end

function class:hpFlg50(status)
   if status == "use" then
      self.isRage = true
   end
end

function class:deadVoge(status)
   if status == "use" and not self.TRIGGERS[self.DEAD_VOGE].used then
      self.isBerserk = true
      self:showMessage(self.DEAD_MESSAGE_LIST)
   end

   if status == "addSP" and self.gameUnit:getBurstPoint() < 100 then
      self.gameUnit:addSP(100)
   end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE or "アルス：水属性キラー",
         COLOR = Color.cyan,
         DURATION = 5         
      }
   }

   self.DEAD_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.DEAD_MESSAGE or "…許さない",
         COLOR = Color.cyan,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.DEAD_MESSAGE or "常に奥義ゲージMAX",
         COLOR = Color.cyan,
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
   self:setMessageBoxList()
   self:setTriggersList()
   self:showMessage(self.START_MESSAGE_LIST)

   self.currentAction = ""
   self.isRage = false
   self.isDeadVoge = false
   self.isBerserk = false
   self.WAIT_TIME = 2.5
   self.waitTimer = 0
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
   self:buddyChecker(event.unit,event.deltaTime)

   if self.isBerserk then
      self:execTrigger(self.DEAD_VOGE,"addSP")
   end
   return 1
end

function class:buddyChecker(unit,deltaTime)
   if self:buddyUnitCatcher(unit,self.VOGE_ID) == nil then
      self.isDeadVoge = true
   end

   if self.isDeadVoge then
      if self.waitTimer >= self.WAIT_TIME then
         self:execTrigger(self.DEAD_VOGE)
      else
         self.waitTimer = self.waitTimer + deltaTime
      end
   end
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

   -- if event.index == 3 and not self.skillCheckFlg2 then
   --    self.skillCheckFlg2 = true;
   --    event.unit:takeSkillWithCutin(3,1);
   --    return 0;
   -- end

   self.skillCheckFlg = false;
   -- self.skillCheckFlg2 = false;
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action(self.currentAction)
   return 1
end

--===================================================================================================================
--トリガー
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   local priorityIndex = nil

   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == self.HP_FLG then
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

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,action)
   if not self:getIsHost() then
      return
   end

   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   self.currentAction = action == nil and "use" or action

   self.TRIGGERS[index].action(self.currentAction)
   self.TRIGGERS[index].used = true
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