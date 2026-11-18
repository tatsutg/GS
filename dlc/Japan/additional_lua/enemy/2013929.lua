local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹怪鳥", version=1.3, id="2013929"})

class.ATTACK_TBL_GROUND = {
   attack1 = 1,
   attack2 = 1,
   attack3 = 1,
}
class.ATTACK_TBL_FLYING = {
   attack4 = 1,
   attack5 = 1
   -- attack6 = 1
}
class.SKILL_TBL_FLYING = {
   skill1 = 1,
   skill2 = 1,
   skill3 = 1
}
class.ACTIONSKILL_TBL = {
   attack1 = 1,
   attack2 = 2,
   attack3 = 3,
   attack4 = 4,
   attack5 = 5,
   attack6 = 6,
   attack7 = 6,
   skill1 = 7,
   skill2 = 8,
   skill3 = 9,
   skill4 = 7
}

class.FIND_COND_ID = 96
class.ANIMATION_LIST = {
   "idle",
   "idle2",
   "damage",
   "damage2"
}


--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [3] = {
         ID = 20139433,
         BUFF_ID = 31, -- 回避
         VALUE = 30,
         DURATION = 999999,
         ICON = 16
      }
   }
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   event.unit:setSPGainValue(0)
   event.unit:setSkillInvocationWeight(0);
   event.unit:setNextAnimationName("idle")
   self.gameUnit = event.unit
   self.spValue = 20
   self.isFlying = true
   self.isFind = false
   self:setBuffBoxList()

   return 1
end

-- ホストでアニメーションを設定してゲストに流す
function class:setBirdAnimation(index)
   if megast.Battle:getInstance():isHost() then
      self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[index])
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,index);
   end
end

function class:receive4(args)
   self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[args.arg])   
   return 1
end


---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)   
   if self.isFlying then 
      self:setBirdAnimation(1)
      -- event.unit:setNextAnimationName("idle")
   else
      self:setBirdAnimation(2)
      -- event.unit:setNextAnimationName("idle2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isFlying then
      self:setBirdAnimation(3)
      -- event.unit:setNextAnimationName("damage")
   else
      self:setBirdAnimation(4)
      -- event.unit:setNextAnimationName("damage2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if "takeOFfEnd" == event.spineEvent then
      self.isFlying = true
      event.unit:takeSkill(self.currentSkill)
   end

   return 1
end


---------------------------------------------------------------------------------
-- break
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isFlying = false
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event) 
   if self.attackFlg == false and megast.Battle:getInstance():isHost() then
      self.attackFlg = true
      local attackKeyName = summoner.Random.sampleWeighted(self:attackTbl())
      local attackStr = string.gsub(attackKeyName,"attack","")
      local attackNo = tonumber(attackStr)
      event.unit:takeAttack(attackNo)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackNo));
      return 0
   end
   self.attackFlg = false
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      unit:takeIdle();
      return 0;
   end
   self.fromHost = false;
   event.unit:addSP(self.spValue)
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["attack"..event.index])
   return 1
end

function class:attackTbl()
   if self.isFlying then
      return self.ATTACK_TBL_FLYING
   end
   return self.ATTACK_TBL_GROUND
end

function class:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeAttackFromHost(unit,index)
    self.fromHost = true;
    unit:takeAttack(index);
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if not self.isFlying then
      self.isFlying = true
      self.skillFlg = true
      event.unit:takeSkill(4)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(4));
      return 0
   end

   if self.skillFlg == false then
      self.skillFlg = true

      local skillKeyName = summoner.Random.sampleWeighted(self.SKILL_TBL_FLYING)
      local skillStr = string.gsub(skillKeyName,"skill","")
      local skillNo = tonumber(skillStr)

      event.unit:takeSkill(skillNo)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillNo));
      return 0
   end
   self.skillFlg = false
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
       unit:takeIdle();
       return 0;
   end
   self.fromHost = false;
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["skill"..event.index])
   return 1
end

function class:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    unit:takeSkill(index);
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
   for i,messageBox in pairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
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
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
end


-- バフ処理実行
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
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end

class:publish();

return class;
