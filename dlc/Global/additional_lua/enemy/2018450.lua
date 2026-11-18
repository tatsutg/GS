local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="シグニット", version=1.3, id=2018450});
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

class.SKILL_PHASE1 = {
    SKILL2 = 100  
}

class.SKILL_PHASE2 = {
    SKILL2 = 100,
    SKILL3 = 100  
}

class.SKILL_PHASE3 = {
   SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20158504,
         BUFF_ID = 17, -- ダメージ
         VALUE = 100,
         DURATION = 999999,
         ICON = 26
      }
   }
end


--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp60(status) end,
         HP = 60,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp40(status) end,
         HP = 40,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp60(status)
   if status == "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      self.SKILL_WEIGHTS = self.SKILL_PHASE2
   end
end


function class:hp40(status)
   if status == "use3" then
      self.isRage = true
      self.isFury = true
      self.isPhase3 = true
      self.gameUnit:addSP(100)
      self.SKILL_WEIGHTS = self.SKILL_PHASE3
   end
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.DEAD_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.DEAD_MESSAGE1 or "…貴様ら…貴様らぁあああああ！！",
         COLOR = Color.magenta,
         DURATION = 5,
         isPlayer = false
      }
   }   
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.isMadness = false
   self.isLastBuff = false
   self.madCounter = 0
   self.isPhase3 = false
   self.hitStop = 0.8
   return 1
end

function class:startWave(event)
   self.riza = self:findUnit(event.unit,300)
   return 1
end
---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   -- self:HPTriggersCheck(self.riza)
   event.unit:setReduceHitStop(2, self.hitStop);
   self:checkParam()
   self:checkMadness(event.unit,event.deltaTime)
   return 1
end


function class:checkParam()
   if self.riza == nil then return end
   if self.riza:getParameter("HP60") == "true" and not self.TRIGGERS[1].used then
      self:execTrigger(1)
   end

   if self.riza:getParameter("HP40") == "true" and not self.TRIGGERS[2].used then
      self:execTrigger(2)
   end   
end
function class:checkMadness(unit,deltaTime)
   if self.isMadness then
      if self.madCounter > 10 then
         unit:setBurstPoint(100)
         if not self.isLastBuff then
            self.isLastBuff = true
            self:showMessage(self.DEAD_MESSAGE_LIST)
            self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
         end
      else
         self.madCounter = self.madCounter + deltaTime
      end
      return
   end
   if not self:findUnit(unit,300) then 
      self.isMadness = true
   end
end

function class:findUnit(unit,unitID)
   for i = 0, 7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == unitID then
         return localUnit
      end
   end
   return nil
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

   if self.isFury and event.index == 3 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   if self.isFury then
      self.isFury = false
      event.unit:setActiveSkill(5)
   elseif self.isPhase3 then
      event.unit:setActiveSkill(summoner.Random.sample({[1]=4,[2]=5}))
   else
      self:skillActiveSkillSetter(event.unit,event.index);
   end
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
      self.isRage = false
      skillIndex = 3
   end

   if self.isMadness or self.isPhase3 then
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end


--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() or unit == nil then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
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

    if buffBox.SCRIPT ~= nil then
       buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
       if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
       if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
       if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
       if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
       if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageAll(messageBoxList)
   return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for i,messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end

class:publish();

return class;