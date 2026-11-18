local class = summoner.Bootstrap.createEnemyClass({label="グラニス", version=1.3, id=102466211});

function class:run(event)
   if event.spineEvent == "ice" then
      self:ice(event.unit)
   end
   return 1
end

function class:ice(unit)
   local iceUnit = unit:addOrbitSystem("ice",0)
   iceUnit:setDamageRateOffset(0.5)
   iceUnit:setBreakRate(0.5)
   unit:setDamageRateOffset(0.5)
   unit:setBreakRate(0.5)
end

class:publish();

return class;

