local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="怪鳥", version=1.3, id="mine_50003"})

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
   -- attack6 = 6,
   skill1 = 7,
   skill2 = 8,
   skill3 = 9,
   skill4 = 7
}

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE,
         COLOR = Color.green,
         DURATION = 5
      }
   }

   self.REMOVE_BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.REMOVE_BUFF_MESSAGE,
         COLOR = Color.green,
         DURATION = 5
      }   
   }

   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE3,
         COLOR = Color.green,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE4,
         COLOR = Color.green,
         DURATION = 5
      }
  }
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
     [0] = {
         ID = 5000031,
         BUFF_ID = 31,      --回避率アップ
         VALUE = math.atan(megast.Battle:getInstance():getCurrentMineFloor()*0.05)*2/math.pi*200+5,       --効果量
         DURATION = 9999999,
         ICON = 16
     },
     [1] = {
         ID = 5000032,
         BUFF_ID = 27,      --ブレイク耐性
         VALUE = -5,
         DURATION = 99999,
         ICON = 0
     }
   }

   self.TIMEUP_BUFF_BOX_LIST = {
     [0] = {
         ID = 5000033,
         BUFF_ID = 17,      --ダメージ
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 26
     },
     [1] = {
         ID = 5000036,
         BUFF_ID = 13,      --攻撃力
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 3
     }
   }
end

--------[[特殊行動フラグ]]--------
function class:setHpTriggersList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [0] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg70(status) end,
         timing = 70,
         used = false
      },
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg30(status) end,
         timing = 30,
         used = false
      },
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
         used = false
      }
   }
end

function class:recoveryBreak()
   self.isBreak = false
end

function class:switchWind(status)
   if self.windUnit == nil then
      self.windUnit = self.gameUnit:addOrbitSystem("wind_roop")
      self.windUnit:setAnimation(0,"wind_roop",true)
      self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
      self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
      self.windUnit:setZOrder(9998);
      self.isWind = true
   end

   if status == "showWindAura" then
      if self.isBreak or self.isFirstBreak then
         return
      end
      
      if self.gameUnit:getTeamUnitCondition():findConditionWithType(self.BUFF_BOX_LIST[0].BUFF_ID) == nil then
        self:execTimeupAddBuff(self.gameUnit,self.BUFF_BOX_LIST[0])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.BUFF_MESSAGE_LIST)
      end

      self.windUnit:setAnimation(0,"wind_roop",true)
   end

   if status == "hideWindAura" then
      self.windUnit:setAnimation(0,"enpty",true)
   end
end

function class:hpFlg70(status)
   -- if status == "use" then
   --    self:switchWind("showWindAura")
   -- end
end

function class:hpFlg30(status)
   -- if status == "use" then
   --    self:switchWind("showWindAura")
   -- end
end

function class:timeUp(status)
   if status == "use" then
      self:execTimeupAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[0])
      self:execTimeupAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   event.unit:setSPGainValue(0)
   event.unit:setNextAnimationName("idle")

   self:setHpTriggersList()
   self:setBuffBoxList()
   self:setMessageBoxList()
   self.gameUnit = event.unit
   self.windUnit = nil

 
   self.addBuffValue = self:multiply()

   self.hitStop = math.floor((megast.Battle:getInstance():getCurrentMineFloor() - 1) / 5) * 0.2 
   self.isFlying = true
   self.isFirstBreak = false
   self.isBreak  = false
   self.attackFlg = false
   self.skillFlg = false

   self.telopSpan = 60
   self.showMessageTimer = 0

   return 1
end

function class:startWave(event)
  self:switchWind("showWindAura")
  return 1;
end

function class:multiply()
   local floor = megast.Battle:getInstance():getCurrentMineFloor();
   local buffValue = math.atan(floor*0.03)*2/math.pi*140;
   return buffValue * -1
end

function class:execSetAnimation(animationName)
   self.gameUnit:setNextAnimationName(animationName)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:telopCheck(event.deltaTime)
   self:setWindPosition(event.unit)
   self:setTimeUp()
   event.unit:setReduceHitStop(2,self.hitStop)

   if self.isBreak and self.gameUnit.m_breaktime <= 0 then
      self:recoveryBreak()
   end
  return 1
end

function class:setWindPosition(unit)
   if self.isWind then
      self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
      self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
   end
end

function class:telopCheck(deltaTime)
   if not self.isFirstBreak then
      if self.showMessageTimer > self.telopSpan then
         self.showMessageTimer = 0
         self:showMessage(self.BUFF_MESSAGE_LIST)
      else
         self.showMessageTimer = self.showMessageTimer + deltaTime
      end
   end
end

function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
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

   if "showWindAura" == event.spineEvent or "hideWindAura" == event.spineEvent then
      self:switchWind(event.spineEvent)
   end

   return 1
end

---------------------------------------------------------------------------------
-- break
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isFlying = false
   self.isBreak = true
   self.isFirstBreak = true
   self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[0].BUFF_ID)
   self:switchWind("hideWindAura")
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

   -- if event.index == 6 then
   --    self:switchWind("showWindAura")
   -- end

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


--HPトリガー
function class:HPTriggersCheck(unit)
  
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

-- TRIGGERテーブルの内容実行。TRIGGER用index定数にはとりあえず頭にTIDをつけとく
function class:execTrigger(index)
   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   self.TRIGGERS[index].used = true
   self.TRIGGERS[index].action("use")

end

--==========================================================================
-- バフ処理実行
--==========================================================================
function class:execAddBuff(unit,buffBox)
  local buff  = nil;
  local correction = self.addBuffValue + buffBox.VALUE

  if buffBox.EFFECT ~= nil then
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
  else
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON);
  end
  if buffBox.SCRIPT ~= nil then
    buff:setScriptID(buffBox.SCRIPT);
  end
  if buffBox.SCRIPTVALUE1 ~= nil then
    buff:setValue1(buffBox.SCRIPTVALUE1);
  end
end

-- 3分オーバー用
function class:execTimeupAddBuff(unit,buffBox)
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
end

-- バフ削除
function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithType(buffId) ~= nil then
      -- local tx = Text:fetchByEnemyID("mine_50003")
      -- summoner.Utility.messageByEnemy("featchByEnemyID使用",5,Color.yellow);
      -- summoner.Utility.messageByEnemy(tx.REMOVE_BUFF_MESSAGE,5,Color.yellow);
      self:showMessage(self.REMOVE_BUFF_MESSAGE_LIST)
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithType(buffId))
      unit:resumeUnit()
    end  
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
