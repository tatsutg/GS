local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒 斎藤一", version=1.8, id=108137512});


---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
   event.unit:setNextAnimationName("in2")
   event.unit:setNextAnimationEffectName("empty")
   return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.skill1Flg = false
   self.skill5Flg = false
   self.skill1BpBonus = 60
   self.skill5PowerPoint = 2300
   self.skill5BreakPoint = 4500
   self:setStartParameter(event.unit)
   return 1
end

function class:setStartParameter(unit)
   if unit:getLevel() >= 90 then
      if unit:getParameter("skill1Flg") == "" then
         unit:setParameter("skill1Flg","false")
      end
   end

   if unit:getParameter("skill5Flg") == "" then
      unit:setParameter("skill5Flg","false")
   end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:setStartWaveParameter(event.unit)
   return 1
end

function class:setStartWaveParameter(unit)
   if unit:getParameter("skill1Flg") == "true" then
      self.skill1Flg = false
      unit:setParameter("skill1Flg","false")
   end

   if unit:getParameter("skill5Flg") == "true" then
      self.skill5Flg = false
      unit:setParameter("skill5Flg","false")
   end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if self.skill1Flg and event.unit:getParameter("skill1Flg") == "false" then
      self.skill1Flg = false
      event.unit:setParameter("skill1Flg","true")
      event.unit:addSPWithPvpCorrection(self.skill1BpBonus)
   end

   if self.skill5Flg and event.unit:getParameter("skill5Flg") == "false" then
      self.skill5Flg = false
      event.unit:setParameter("skill5Flg","true")
      event.unit:getActiveBattleSkill():setDamageRate(self.skill5PowerPoint * 2)
      event.unit:getActiveBattleSkill():setBreakValue(self.skill5BreakPoint * 2)
   elseif self.skill5Flg then
      self.skill5Flg = false
      event.unit:getActiveBattleSkill():setDamageRate(self.skill5PowerPoint)
      event.unit:getActiveBattleSkill():setBreakValue(self.skill5BreakPoint)
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 1 then
      self.skill1Flg = true
   elseif event.index == 5 then
      self.skill1Flg = false
      self.skill5Flg = true
   end
   return 1
end



class:publish();

return class;