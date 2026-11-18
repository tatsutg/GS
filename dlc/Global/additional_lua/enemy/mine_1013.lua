local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="シェイド", version=1.3, id=10013})

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   -- event.unit:addSP(100)
   -- event.unit:setRange_Max(2000)
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
