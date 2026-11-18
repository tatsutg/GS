local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="岩谷", version=1.9, id=107255411});

class.ANIMATION_LIST = {
   SUCCESS_SKILL1 = "skill1_2",
   SUCCESS_SKILL3 = "skill3orbit",
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
         VALUE = 6000,
         DURATION = 15,
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
   self.targetUnit = nil
   self.shieldPrisonOrbit = nil
   self.visible = 1
   self.isShowing = false
   self.isReflect = false
   self.isPrison = false
   self.targetUnitList = {}
   self:setBuffBoxList()
   self.ADD_WEAPON = 4000


   if self:findWeapon(event.unit,50261600) then
      self.OGI_BUFF_LIST[1].VALUE = 6000 + self.ADD_WEAPON
   end
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
   self.targetUnit = nil
   self.targetUnitList = {}
   if event.unit:getParameter("isBarrier") ~= "true" then
      self:addBarrier(event.unit)
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
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "reflectStart" then self:startReflect() end
   if event.spineEvent == "reflectEnd"   then self:endReflect() end
   if event.spineEvent == "ShieldPrisonStart" then self:startShieldPrison(event.unit) end
   if event.spineEvent == "check"        then self:checkTarget(event.unit) end
   if event.spineEvent == "checkStart" then self:startCheck() end
   if event.spineEvent == "missEnd"      then self:endMiss() end
   if event.spineEvent == "enemyShow"    then self:showEnemy() end
   --if event.spineEvent == "skill2"       then self:skill2(event.unit) end
   return 1
end

function class:skill2(unit)
   if self.gameUnit:getIndex() ~= unit:getIndex() then return end

   if self:findWeapon(self.gameUnit,50261600) then
      self.OGI_BUFF_LIST[1].VALUE = 6000 + self.ADD_WEAPON
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
   self.isSuccess = false
   self.targetUnitList = {}
end

-- ターゲットは同期させる
function class:startShieldPrison(unit)
   self.visible = 1
   self.isShowing = false
   self.shieldPrisonOrbit = unit:addOrbitSystemWithFile(self.FILE_NAME,self.ANIMATION_LIST.SUCCESS_SKILL3)
   self.targetUnit = unit:getTargetUnit()
   if megast.Battle:getInstance():isHost() and self.targetUnit ~= nil then
      megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, self.targetUnit:getIndex());
      self:checkNil(self.targetUnit,"setOpacity",{unit = self.targetUnit,value = math.ceil(self.visible)})
   end
end

function class:receive1(args)
   self.targetUnit = self:getUnit(self.gameUnit,args.arg)
   self:checkNil(self.targetUnit,"setOpacity",{unit = self.targetUnit,value = math.ceil(self.visible)})
   return 1
end

function class:getUnit(unit,index)
   return megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index)
end


function class:checkTarget(unit)
   self.isPrison = true
   if not self:checkBuff(self.targetUnitList,self.STAN_ID) then
      if not self.isSuccess then
         self:execTakeAnimation(self.gameUnit,self.ANIMATION_LIST.MISS_SKILL3,false)
         self:execTakeAnimation(self.shieldPrisonOrbit,self.ANIMATION_LIST.MISS_SKILL3_EF,true)
         unit:takeHeal(unit:getCalcHPMAX() * 0.5,self.gameUnit)
         unit:addSPWithPvpCorrection(80)
      end
   end
end

-- 成否判定も同期させる
function class:checkBuff(unitList,buffID)
   if not megast.Battle:getInstance():isHost() then return false end
   for _,unit in pairs(unitList) do
      local teamUnit = unit:getTeamUnitCondition():findConditionWithType(buffID)
      if teamUnit ~= nil then
         self.isSuccess = true
         --self:addBuff(self.gameUnit,self.BUFF_SUCCESS_LIST)
         megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, 1);
         return self.isSuccess
      end
   end

   self.isSuccess = false
   --self:addBuff(self.gameUnit,self.BUFF_MISS_LIST)
   megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, 2);

   return self.isSuccess
end

function class:receive2(args)
   if args.arg == 1 then
      self.isSuccess = true
      --self:addBuff(self.gameUnit,self.BUFF_SUCCESS_LIST)
   else
      self.isSuccess = false
      --self:addBuff(self.gameUnit,self.BUFF_MISS_LIST)
   end
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
   self.isCheck = false
   --self:removeBuff(self.gameUnit,self.BUFF_SUCCESS_LIST)
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
   self:checkNil(self.targetUnit,"setOpacity",{unit = self.targetUnit,value = 255})
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:checkShowTarget(event.deltaTime)
   --self:checkTargetPosition(event.unit)
   return 1
end

function class:checkShowTarget(deltaTime)
   if self.isShowing then
      self.visible = self:changeValue(self.visible,self.VISIBLE_MAX,self.VISIBLE_MAX / self.SHOW_INTERVAL * deltaTime)
      if self.visible == self.VISIBLE_MAX then
         self.isShowing = false
      end
      self:checkNil(self.targetUnit,"setOpacity",{unit = self.targetUnit,value = math.ceil(self.visible)})
   end
end

function class:changeValue(start,finish,val)
   if start + val < finish then return start + val elseif
   start - val > finish then return start - val end
   return finish
end

function class:checkNil(unit,funcName,args)
   if unit ~= nil then self.FUNC_LIST[funcName](args) end
end

--function class:checkTargetPosition(unit)
--   if self.isPrison and self.shieldPrisonOrbit ~= nil and self.visible < self.VISIBLE_MAX then
--      local vec = self.shieldPrisonOrbit:getisPlayer() and 1 or -1
--      local boneX = self.shieldPrisonOrbit:getSkeleton():getBoneWorldPositionX("ShieldPrison") + unit:getPositionX() or self.shieldPrisonOrbit:getPositionX();
--      local boneY = self.shieldPrisonOrbit:getSkeleton():getBoneWorldPositionY("ShieldPrison") + unit:getPositionY() or self.shieldPrisonOrbit:getPositionY();
--      self:checkNil(self.targetUnit,"setPosition",{unit = self.targetUnit,x = boneX * vec ,y = boneY})
--   end
--end


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
-- ターゲットはホストが管理
function class:attackDamageValue_OrbitSystem(event)
   if self.isCheck and megast.Battle:getInstance():isHost() then
      self.targetUnitList[event.enemy:getIndex() + 1] = event.enemy
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
