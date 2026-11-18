local class = summoner.Bootstrap.createUnitClass({label="戸愚呂", version=1.9, id=107336512});

class.MAX_VALUE = 150

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1073365121,
         BUFF_ID = 13, -- 攻撃力
         VALUE = 0,
         DURATION = 999999,
         ICON = 3,
         COUNT = 0,
         MAX = 15
      },
      [2] = {
         ID = 1073365122,
         BUFF_ID = 15, -- 防御力
         VALUE = 0,
         DURATION = 999999,
         ICON = 5,
         COUNT = 0,
         MAX = 15
      }
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   self.buffValue = 0
   self.CHECK_ID = 107330
   self.checkTimer = 0
   if event.unit:getParameter("defaultDamage") ~= "" then
      self.defaultDamage = event.unit:getParameter("defaultDamage")
   else
      self.defaultDamage = event.unit:getBurstSkill2():getDamageRate()
      event.unit:setParameter("defaultDamage",self.defaultDamage)
   end
   self:setBuffBoxList()
   return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   self:influenceLastAttackChecker(event.unit)
   return event.value
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:checkDeath3(self:getAncestorUnit(event.unit),event.deltaTime)
   return 1
end

function class:checkDeath3(unit,deltaTime)
   self.checkTimer = self.checkTimer + deltaTime
   if  self.checkTimer < 0.2 then return end
   self.checkTimer = self.checkTimer - 0.2

   local targetList =  self:getTargetList(unit)

   for _,index in pairs(targetList) do
      if self:deadOrNew(unit,index) then
         if self.buffValue < self.MAX_VALUE then
            self.buffValue = self.buffValue + 10
            self:execAddStatus(unit,self.buffValue)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffValue);
            self:cleanUpTargetParam(unit,index);
         end
      end
   end
   --self:influenceLastAttackChecker(unit);
end

function class:receive1(args)
   self.buffValue = args.arg
   self:execAddStatus(self.gameUnit,args.arg)
   return 1
end

function class:getTargetList(unit)
   local key = self:createKey("lastAttackChecker",unit:getIndex(),"index")
   local lst = {}
   for i=0,7 do
      local param = unit:getParameter(key..i);
      if param ~= "" and param ~= nil and param ~= "error" then
         local lastAttackerIndex = tonumber(param);
         if lastAttackerIndex == unit:getIndex() then
            table.insert(lst,i);
         end
      end
   end
   return lst
end

function class:createKey(key,index,key2)
   return key .. index .. key2
end

function class:deadOrNew(unit,index)
   local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index,true)
   local buffID = self.CHECK_ID + unit:getIndex();
   if target ~= nil then
      local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
      if buff == nil then
         return true;
      end
   end

   return target == nil or target:getHP() <= 0;
end

function class:cleanUpTargetParam(unit,index)
   local key = self:createKey("lastAttackChecker",unit:getIndex(),"index")
   unit:setParameter(key..index,"-1");
end

function class:influenceLastAttackChecker(unit)
   if not megast.Battle:getInstance():isHost() then return end
   local buffID = self.CHECK_ID + unit:getIndex();
   for i=0,7 do
      local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i,true);
      if target ~= nil then
         local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
         if buff == nil and target:getHP() > 0 then
            buff = target:getTeamUnitCondition():addCondition(buffID,21,1,99999,0);
            buff:setScriptID(179);
            buff:setValue1(unit:getIndex());
         end
      end
   end
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
   self:influenceLastAttackChecker(self:getAncestorUnit(event.unit))
   return event.value
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
   if unit:getParentTeamUnit() == nil then
      return unit
   else
      return self:getAncestorUnit(unit:getParentTeamUnit())
   end
end

function class:execAddStatus(unit,value)
   self.BUFF_BOX_LIST[1].VALUE = value
   self.BUFF_BOX_LIST[2].VALUE = value
   self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
   self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 3 then
      self:addDamage(event.unit)
   end
   return 1
end

function class:addDamage(unit)
   local attackVal = unit:getCalcAttack();
   local sum = unit:getCalcHPMAX() + attackVal + unit:getCalcDefence()
   local value = self.defaultDamage + (sum/100)

   unit:getBurstSkill2():setDamageRate(value)
end


--====================================================================================
function class:calcAttack(power,unit)
   local offset = self:getOffset(unit)
   local attack = 3500 * power * offset / (7000 - power * offset)
   return math.floor(attack)
end

function class:getOffset(unit)
   if megast.Battle:getInstance():isArena() then
      return 200
   end
   if unit:getisPlayer() then
      return 10
   else
      return 100
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
      buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
      if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
      if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
      if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
      if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
      if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
   end

   buffBox.COUNT = (self.buffValue / 10) < buffBox.MAX and (self.buffValue / 10) or buffBox.MAX
   buff:setMaxConditionIconNumber(buffBox.MAX);
   buff:setNumber(buffBox.COUNT);
   megast.Battle:getInstance():updateConditionView();
end

class:publish();

return class;