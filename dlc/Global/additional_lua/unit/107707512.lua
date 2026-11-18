local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒アルベド", version=1.3, id=107707512});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   if event.unit:getParameter("used") ~= "false" and event.unit:getParameter("used") ~= "true" then
      event.unit:setParameter("used","false")
   end
   self.gameUnit = event.unit
   event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
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
      unit:addSPWithPvpCorrection(300);
      local myTeam = unit:getTeam()
      for i = 0,6 do
         local myTeamUnit = myTeam:getTeamUnit(i)
         if myTeamUnit ~= nil then
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX() * 0.5,unit)
         end
      end
   end
end

class:publish();

return class;