local class = summoner.Bootstrap.createEnemyClass({label="アバドン", version=1.3, id=100606512});

function class:run(event)
   if event.spineEvent == "3flame" then
      self:createOrbit(event.unit,"3flame")
   end

   if event.spineEvent == "4flame" then
      self:createOrbit(event.unit,"4flame")
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