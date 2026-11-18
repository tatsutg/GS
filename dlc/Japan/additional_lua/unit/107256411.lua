local class = summoner.Bootstrap.createUnitClass({label="岩谷", version=2.6, id=107256411});

class.ANIMATION_LIST = {
   SUCCESS_SKILL1 = "skill1_2",
   SUCCESS_SKILL3 = "skill3orbit",
   SUCCESS_SKILL3_2 = "success",
   MISS_SKILL3 = "skill3_2",
   MISS_SKILL3_EF = "2-skill3_miss",
   END_ANIMATION = "empty"
}

class.FILE_NAME = "10725ef"
class.SHOW_INTERVAL = 0.2
class.VISIBLE_MAX = 255
-- 気絶チェック
class.STAN_ID = 89

-- nilチェックをifじゃなくて関数でやりたかっただけなのに設定項目が色々増えてしもうた。。。
-- 実行方法も複雑だし。楽するつもりが遠回り
class.FUNC_LIST = {
   setOpacity = function (tbl) tbl.unit:setOpacity(tbl.value) end,
   setPosition = function (tbl) tbl.unit:setPositionX(tbl.x) end
}

function class:setBuffBoxList()
   self.BUFF_START_LIST = {
      [1] = {
         ID = 1072564111,
         BUFF_ID = 98, -- 被ダメ無効
         VALUE = 3000,
         DURATION = 20,
         ICON = 24,
         EFFECT = 1
      }
   }

   self.BUFF_MISS_LIST = {
      [1] = {
         ID = 1072564113,
         BUFF_ID = 4, -- HP回復
         VALUE = 50,
         DURATION = 1,
         ICON = 26
      }
   }
   self.OGI_BUFF_LIST = {
      [1] = {
         ID = 1072564114,
         BUFF_ID = 98, -- 被ダメ無効
         VALUE = 11000,
         DURATION = 20,
         ICON = 24,
         EFFECT = 1,
         GROUP_ID = 1031,
         PRIORITY = 100
      }
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   self.targetUnitIndex = 0
   self.shieldPrisonOrbit = nil
   self.visible = 1
   self.isShowing = false
   self.isReflect = false
   self.isPrison = false
   self.targetUnitList = {}
   self:setBuffBoxList()

   self.isFirst = false
   self.prisonX = 0
   self.prisonY = 0
   self.ADD_WEAPON = 4000

   return 1
end

function class:findWeapon(unit,weaponId)
   local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
   return buff ~= nil
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self.isReflect = false
   self.targetUnitIndex = 0
   self.targetUnitList = {}
   if event.unit:getParameter("isBarrier") ~= "true" then
      --self:addBarrier(event.unit)
      event.unit:setParameter("isBarrier","true")
   end
   return 1
end
function class:addBarrier(unit)
   for i = 0, 7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil then
         self:addBuff(localUnit,self.BUFF_START_LIST)
      end
   end
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
   event.unit:getStartWaveOnceSkill():runSkillEffect(0);
   return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "reflectStart" then self:startReflect() end
   if event.spineEvent == "reflectEnd"   then self:endReflect() end
   if event.spineEvent == "ShieldPrisonStart" then self:startShieldPrison(event.unit) end
   if event.spineEvent == "check"        then self:checkTarget() end
   if event.spineEvent == "checkStart" then self:startCheck() end
   if event.spineEvent == "missEnd"      then self:endMiss() end
   if event.spineEvent == "enemyShow"    then self:showEnemy() end
   --if event.spineEvent == "skill2"       then self:skill2(event.unit) end
   return 1
end

function class:skill2(unit)
   if self.gameUnit:getIndex() ~= unit:getIndex() then return end

   if self:findWeapon(self.gameUnit,50261600) then
      self.OGI_BUFF_LIST[1].VALUE = 11000 + self.ADD_WEAPON
   end
   self:execAddBuff(self.gameUnit,self.OGI_BUFF_LIST[1])
end

function class:startReflect()
   self.isReflect = true
end

function class:endReflect()
   self.isReflect = false
end

function class:startCheck()
   self.isCheck = true
   self.targetUnitList = {}
end

-- ターゲットは同期させる
function class:startShieldPrison(unit)
   if not self:isHost() then return end
   if unit:getTargetUnit() == nil then return end

   self.targetUnitIndex = unit:getTargetUnit():getIndex()
   self:setPrison(unit,self.targetUnitIndex,self.ANIMATION_LIST.SUCCESS_SKILL3,0.01)
   megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, self.targetUnitIndex);
end

function class:setPrison(unit,targetIndex,animationName,weight)
   local target = self:getUnit(unit,targetIndex)
   if target ~= nil then
      self.visible = 1
      self.isShowing = false
      self.shieldPrisonOrbit = unit:addOrbitSystemWithFile(self.FILE_NAME,animationName)
      self.shieldPrisonOrbit:setDamageRateOffset(weight)
      self.shieldPrisonOrbit:setBreakRate(weight)
      self:setPrisonPosition(target)
      self:checkNil(targetIndex,"setOpacity",{value = math.ceil(self.visible)})
   end
end

function class:setPrisonPosition(target)
   local vec = target:getisPlayer() and 1 or -1
   local targetX = target:getPositionX() + target:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targetY = target:getPositionY();

   self.isFirst = true
   self.prisonX = targetX
   self.prisonY = targetY + 400
   self.shieldPrisonOrbit:setPosition(targetX,targetY)
end

function class:receive1(args)
   self.targetUnitIndex = args.arg
   self:setPrison(self.gameUnit,args.arg,self.ANIMATION_LIST.SUCCESS_SKILL3,0.01)
   return 1
end

function class:getUnit(unit,index)
   return megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index)
end

-- 成否判定も同期させる
function class:checkTarget()
   if not self:isHost() then return end

   self.isPrison = true
   self.isCheck = false
   self:checkBuff(self.targetUnitList,self.STAN_ID)
   self:showOtherEnemy(self.targetUnitList,self.targetUnit)
end

function class:checkBuff(unitList,buffID)
   for _,index in pairs(unitList) do
      local target = self:getUnit(self.gameUnit,index)
      if target ~= nil and target:getHP() > 0 then
         local teamUnit = target:getTeamUnitCondition():findConditionWithType(buffID)
         if teamUnit ~= nil then
            self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.END_ANIMATION,true)
            self:setPrison(self.gameUnit,index,self.ANIMATION_LIST.SUCCESS_SKILL3_2,0.99)
            self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.SUCCESS_SKILL3_2,true)
            self.targetUnitIndex = index
            local target = self:getUnit(self.gameUnit,index)
            self:setPrisonPosition(target)
            self.pvpChecked = true
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, index);
            return
         end
      end
   end

   self:execTakeAnimation(self.gameUnit,self.ANIMATION_LIST.MISS_SKILL3,false)
   self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.MISS_SKILL3_EF,true)
   self.gameUnit:takeHeal(self.gameUnit:getCalcHPMAX() * 0.6,self.gameUnit)
   self.gameUnit:addSPWithPvpCorrection(100)
   megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, 9);
end

function class:showOtherEnemy(targetList,targetUnit)
   for _,value in pairs(targetList) do
      local unit = self:getUnit(self.gameUnit,value)
      if unit ~= targetUnit then
         if unit:getIndex() ~= self.targetUnitIndex then
            self:checkNil(unit:getIndex(),"setOpacity",{value = self.VISIBLE_MAX})
         end
      end
   end
end

function class:isHost()
   local bool = false
   if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
      bool = true
   end
   return bool
end

function class:receive2(args)
   if args.arg == 9 then
      self:execTakeAnimation(self.gameUnit,self.ANIMATION_LIST.MISS_SKILL3,false)
      self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.MISS_SKILL3_EF,true)
      self.gameUnit:takeHeal(self.gameUnit:getCalcHPMAX() * 0.6,self.gameUnit)
      self.gameUnit:addSPWithPvpCorrection(100)
   else
      self.targetUnitIndex = args.arg
      self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.END_ANIMATION,true)
      self:setPrison(self.gameUnit,args.arg,self.ANIMATION_LIST.SUCCESS_SKILL3_2,0.99)
      self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.SUCCESS_SKILL3_2,true)
      self:setPrisonPosition(self:getUnit(self.gameUnit,args.arg))
      self.pvpChecked = true
   end
   self:showOtherEnemy(self.targetUnitList,self.targetUnit)
   return 1
end

function class:endMiss()
   self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.END_ANIMATION,true)
   self:showEnemy()
end

function class:showEnemy()
   self.isPrison = false
   self.isShowing = true
   self.isSuccess = false
   self.pvpChecked = false
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   self.isReflect = false
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self.isReflect = false
   return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   self.isReflect = false
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   self.visible = 255
   self.isReflect = false
   -- self:endMiss()
   self:checkNil(self.targetUnitIndex,"setOpacity",{value = 255})
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:checkShowTarget(event.deltaTime)
   if  megast.Battle:getInstance():isPvp() then
      self:pvp()
   end
   return 1
end

function class:pvp()
   if self:getUnit(self.gameUnit,self.targetUnitIndex) ~= nil and self.pvpChecked and self.isFirst then
      self:getUnit(self.gameUnit,self.targetUnitIndex):setPosition(self.prisonX,self.prisonY)
   end
end

function class:checkShowTarget(deltaTime)
   if self.isShowing then
      self.visible = self:changeValue(self.visible,self.VISIBLE_MAX,self.VISIBLE_MAX / self.SHOW_INTERVAL * deltaTime)
      if self.visible == self.VISIBLE_MAX then
         self.isShowing = false
      end
      self:checkNil(self.targetUnitIndex,"setOpacity",{value = math.ceil(self.visible)})
   end
end

function class:changeValue(start,finish,val)
   if start + val < finish then return start + val elseif
   start - val > finish then return start - val end
   return finish
end

function class:checkNil(unitIndex,funcName,args)
   if unitIndex == nil then return end
   local unit = self:getUnit(self.gameUnit,unitIndex)
   if unit ~= nil then
      args.unit = unit
      self.FUNC_LIST[funcName](args)
   end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isReflect then self:successReflect(event.unit) end
   return event.value
end


function class:successReflect(unit)
   self:execTakeAnimation(unit,self.ANIMATION_LIST.SUCCESS_SKILL1)
   self.isReflect = false
end

function class:execTakeAnimation(unit,animationName,isLoop,isEffect)
   if unit == nil then return end
   if isEffect then
      unit:takeAnimationEffect(0,animationName,isLoop);
   else
      unit:takeAnimation(0,animationName,isLoop)
   end

end


---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
   if self.isCheck then
      self.targetUnitList[event.enemy:getIndex() + 1] = event.enemy:getIndex()
   end
   return event.value
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end

function class:execAddBuff(unit,buffBox)
   local buff  = nil;
   if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
      elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
         return;
      end
   end

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

   if buffBox.GROUP_ID ~= nil then
      buff:setGroupID(buffBox.GROUP_ID);
      buff:setPriority(buffBox.PRIORITY);
   end
end

function class:removeBuff(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execRemoveCondition(unit,buffBox.ID)
   end
end

function class:execRemoveCondition(unit,buffId)
   if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
   end
end

class:publish();

return class;
