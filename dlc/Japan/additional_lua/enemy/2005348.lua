local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ヴォーグ", version=1.3, id=2005348});
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

class.ARUSU_ID = 3

--------[[特殊行動フラグ]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 0
   self.DEAD_ARUSU = 1

   self.TRIGGERS = {
      [self.HP_50] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [self.DEAD_ARUSU] = {
         tag = "DEAD_ARUSU",
         action = function (status) self:deadArusu(status) end,
         used = false
      }
   }
end

function class:hpFlg50(status)
   if status == "use" then
      self.isRage = true
   end
end

function class:deadArusu(status)
   if status == "use" and not self.TRIGGERS[self.DEAD_ARUSU].used then
      self:addBuff(self.gameUnit,self.BUFF_BOX_LIST_2)
      self:showMessage(self.DEAD_MESSAGE_LIST)
   end
end

----------[[バフ]]----------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 20053481,
         BUFF_ID = 22,         --クリティカルUP
         VALUE = 30,        --効果量
         DURATION = 9999999,
         ICON = 11,
         COUNT = 1,
         COUNT_MAX = 5
      }
   }

   self.BUFF_BOX_LIST_2 = {
      [0] = {
         ID = 20053482,
         BUFF_ID = 13,         --攻撃力UP
         VALUE = 100,        --効果量
         DURATION = 9999999,
         ICON = 3
      },
      [1] = {
         ID = 20053483,
         BUFF_ID = 17,      --ダメージUP
         VALUE = 100,        --効果量
         DURATION = 9999999,
         ICON = 26
      }
   }

end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE or "ヴォーグ：回避率アップ",
         COLOR = Color.green,
         DURATION = 5         
      }
   }

   self.DEAD_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.DEAD_MESSAGE1 or "師匠の仇…討つ！",
         COLOR = Color.green,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.DEAD_MESSAGE2 or "攻撃力・ダメージUP",
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
   self.gameUnit = event.unit;
   self:setMessageBoxList()
   self:setTriggersList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)

   self.currentAction = ""
   self.isRage = false
   self.isDeadArusu = false
   self.WAIT_TIME = 2.5
   self.waitTimer = 0

   self.hpMarkers = {
      {
         HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
      }
   }
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

   for _,marker in pairs(self.hpMarkers) do
      local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
      if not marker.isUsed and hpPercent < marker.HP then
         marker.isUsed = true
         event.unit:removeHpMarker(marker.MARKER)
      end
   end
   return 1
end

function class:buddyChecker(unit,deltaTime)
   if self:buddyUnitCatcher(unit,self.ARUSU_ID) == nil then
      self.isDeadArusu = true
   end

   if self.isDeadArusu then
      if self.waitTimer >= self.WAIT_TIME then
         self:execTrigger(self.DEAD_ARUSU)
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

   if event.index == 2 then
      self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
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

--===================================================================================================================
-- バフ処理実行
function class:addBuff(unit,buffBoxList,index)
  if index == nil then 
      self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
      return
  end
  self:execAddBuff(unit,buffBoxList[index])
end

function class:addBuffRange(unit,buffBoxList,start,finish)
  for i = start,finish do
      self:execAddBuff(unit,buffBoxList[i])
  end
end

function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

   if buffBox.SCRIPT ~= nil then
      buff:setScriptID(buffBox.SCRIPT);
   end
   if buffBox.SCRIPTVALUE1 ~= nil then
      buff:setValue1(buffBox.SCRIPTVALUE1);
   end

   if buffBox.COUNT ~= nil then
      buff:setNumber(buffBox.COUNT)
      megast.Battle:getInstance():updateConditionView()
      if buffBox.COUNT < buffBox.COUNT_MAX then
         buffBox.COUNT = buffBox.COUNT + 1
         self:incBuffValue(buffBox,30)
      end
   end
end

-- バフ効果量インクリメント
function class:incBuffValue(buffBox,value)
   buffBox.VALUE = buffBox.VALUE + value
end

class:publish();

return class;