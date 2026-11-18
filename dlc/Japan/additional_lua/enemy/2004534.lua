local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="炎怪鳥", version=1.3, id="2004534"})

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

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "ブレイク耐性・回避率アップ",
         COLOR = Color.yellow,
         DURATION = 10
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "毒状態時、ブレイク耐性・回避率ダウン",
         COLOR = Color.yellow,
         DURATION = 10
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージ無効化解除",
         COLOR = Color.yellow,
         DURATION = 10
      }
   }
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [0] = {
         ID = 2004534,
         BUFF_ID = 27, -- ブレイク耐性DOWN
         VALUE = 0,
         DURATION = 999999,
         ICON = 10
      },
      [1] = {
         ID = 20045342,
         BUFF_ID = 31, -- 回避率DOWN
         VALUE = 0,
         DURATION = 999999,
         ICON = 17
      }
   }
end

class.FIND_COND_ID = 90

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   event.unit:setSPGainValue(0)
   event.unit:setNextAnimationName("idle")
   self.isFlying = true
   self:setMessageBoxList()
   self:setBuffBoxList()
   self.isFind = false

   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end


---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)   
   if self.isFlying then 
      event.unit:setNextAnimationName("idle")
   else
      event.unit:setNextAnimationName("idle2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isFlying then 
      event.unit:setNextAnimationName("damage")
   else
      event.unit:setNextAnimationName("damage2")
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
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if self.isFind and not self:findCondition(event.unit,self.FIND_COND_ID) then
      self:removeCondition(event.unit,self.BUFF_LIST[0].ID)
      self:removeCondition(event.unit,self.BUFF_LIST[1].ID)
      self.isFind = false
   end

   if not self.isFind and self:findCondition(event.unit,self.FIND_COND_ID) then
      self:execAddBuff(event.unit,self.BUFF_LIST[0])
      self:execAddBuff(event.unit,self.BUFF_LIST[1])
      self.isFind = true
   end

   return 1
end

function class:findCondition(unit,buffID)
   local buff = unit:getTeamUnitCondition():findConditionWithType(buffID);
   if buff ~= nil then
      return true
   end   
   return false
end

function class:removeCondition(unit,buffID)
   local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
   if buff ~= nil then
      unit:getTeamUnitCondition():removeCondition(buff);
   end 
end

function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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
      return 0
   end
   self.attackFlg = false

   event.unit:addSP(20)
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["attack"..event.index])
   return 1
end

function class:attackTbl()
   if self.isFlying then
      return self.ATTACK_TBL_FLYING
   end
   return self.ATTACK_TBL_GROUND
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if not self.isFlying then
      self.isFlying = true
      self.skillFlg = true
      event.unit:takeSkill(4)
      return 0
   end

   if self.skillFlg == false then
      self.skillFlg = true

      local skillKeyName = summoner.Random.sampleWeighted(self.SKILL_TBL_FLYING)
      local skillStr = string.gsub(skillKeyName,"skill","")
      local skillNo = tonumber(skillStr)

      event.unit:takeSkill(skillNo)
      return 0
   end
   self.skillFlg = false
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["skill"..event.index])
   return 1
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

class:publish();

return class;
