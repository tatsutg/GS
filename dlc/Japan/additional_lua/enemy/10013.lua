local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="シェイド", version=1.3, id=10013})

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.timer = 0
   self.TIME_LIMIT = 10
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if self.timer < self.TIME_LIMIT then
      self.timer = self.timer + event.deltaTime
   else
      event.unit:addSP(100)
   end
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "explosion" then
      event.unit:setHP(0)
   end
   return 1
end

class:publish();

return class;
