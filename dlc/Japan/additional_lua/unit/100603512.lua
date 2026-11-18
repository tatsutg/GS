local class = summoner.Bootstrap.createEnemyClass({label="アバドン", version=1.3, id=100603512});

function class:run(event)
   if event.spineEvent == "1flame" then
      self:createOrbit(event.unit,"1flame")
   end
   return 1
end

function class:createOrbit(unit,animationName)
   local orbit = unit:addOrbitSystemWithFile("10060ef",animationName)
   orbit:setDamageRateOffset(0.5)
   orbit:setBreakRate(0.5)
   unit:setDamageRateOffset(0.5)
   unit:setBreakRate(0.5)
end

function class:takeAttack(event)
   event.unit:setDamageRateOffset(1)
   event.unit:setBreakRate(1)
   return 1
end

function class:takeSkill(event)
   event.unit:setDamageRateOffset(1)
   event.unit:setBreakRate(1)
   return 1
end

class:publish();

return class;