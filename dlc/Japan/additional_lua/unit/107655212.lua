local class = summoner.Bootstrap.createUnitClass({label="三ツ谷", version=1.3, id=107655212});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   if event.unit:getParameter("used") ~= "false" and event.unit:getParameter("used") ~= "true" then
      event.unit:setParameter("used","false")
   end
   self.gameUnit = event.unit
   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if event.unit:getParameter("used") == "false" then
      self:checkHp(event.unit)
   end
   return 1
end

function class:checkHp(unit)
   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   if hpRate <= 40 and unit:getLevel() >= 1 then
      unit:setParameter("used","true")
       unit:addSPWithPvpCorrection(200);
       unit:takeHeal(unit:getCalcHPMAX() * 0.5,unit)
   end
end

class:publish();

return class;