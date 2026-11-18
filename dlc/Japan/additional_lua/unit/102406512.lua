local class = summoner.Bootstrap.createUnitClass({label="闇ゼイオルグ", version=1.3, id=102406512});

class.ADD_SP_VALUE = 2
class.DURATION = 12

----------[[バフ]]----------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 2010010,
         BUFF_ID = 70,         --HP吸収
         VALUE = 4,        --効果量
         DURATION = 12,
         ICON = 18,
         GROUP_ID = 3207,
         PRIORITY = 4
      }
   }
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if "addBuff" == event.spineEvent then
      self:addBuff(event.unit,self.BUFF_BOX_LIST[0])
   end
   return 1
end
---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
  self:setBuffBoxList()
  self.timer = 0
  return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if self.timer > 0 then
    self.timer = self.timer - event.deltaTime;
  end
  return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if event.index == 3 then
    self.timer = self.DURATION
  end
  return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  if self.timer > 0 then
    event.unit:addSPWithPvpCorrection(self.ADD_SP_VALUE)
  end
  return event.value
end

--===================================================================================================================
-- バフ
--===================================================================================================================
function class:addBuff(unit,buffBox)
  if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
         local newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,self.gameUnit,buffBox.ICON);
         newCond:setGroupID(buffBox.GROUP_ID);
         newCond:setPriority(buffBox.PRIORITY);
         if buffBox.SCRIPT_ID ~= nil then
           newCond:setScriptID(buffBox.SCRIPT_ID)
         end
      elseif cond == nil then
         local newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,self.gameUnit,buffBox.ICON);
         newCond:setGroupID(buffBox.GROUP_ID);
         newCond:setPriority(buffBox.PRIORITY); 
         if buffBox.SCRIPT_ID ~= nil then
            newCond:setScriptID(buffBox.SCRIPT_ID)
         end
      end
  end
end

class:publish();

return class;