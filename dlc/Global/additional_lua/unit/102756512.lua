local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="闇フェン", version=1.3, id=102756512});

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.RATE = 1

   self.skill2DamageRate = 0
   self:checkBurstSkillRate(event.unit);
   return 1
end

function class:checkBurstSkillRate(unit)
  local param = unit:getParameter("skill2DamageRate")
  if param == "" then
    self.skill2DamageRate = unit:getBurstSkill():getDamageRate();
    unit:setParameter("skill2DamageRate",""..self.skill2DamageRate);
  else
    self.skill2DamageRate = tonumber(param);
  end
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 2 then
      local condValue = event.unit:getTeamUnitCondition():findConditionValue(32)
      self:addDamage(event.unit,self.skill2DamageRate + (condValue * self.RATE))
   end
   return 1
end

function class:addDamage(unit,value)
   unit:getBurstSkill():setDamageRate(value)
end
class:publish();

return class;