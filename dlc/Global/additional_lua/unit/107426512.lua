local class = summoner.Bootstrap.createUnitClass({label="正月リムル", version=1.3, id=107426512});

function class:run(event)
   if event.spineEvent == "Top_shot" then
      self:createOrbit(event.unit,"Top_shot")
   end
   return 1
end

function class:createOrbit(unit,animationName)
   local orbit = unit:addOrbitSystemWithFile("10742ef",animationName)
   orbit:setDamageRateOffset(0.5)
   orbit:setBreakRate(0.5)
end

function class:takeAttack(event)
   event.unit:setDamageRateOffset(1)
   event.unit:setBreakRate(1)
   return 1
end


function class:takeSkill(event)
   event.unit:setDamageRateOffset(1)
   event.unit:setBreakRate(1)
   if event.index == 2 then
      event.unit:setDamageRateOffset(0.5)
      event.unit:setBreakRate(0.5)
   end
   return 1
end


class:publish();

return class;