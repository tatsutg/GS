local class = summoner.Bootstrap.createEnemyClass({label="シビル", version=1.3, id="102775512"});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   self.ADD_SP_VALUE = 20
   self.isOugi = false
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self.isOugi = false
   return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   if self.isOugi and event.unit == self.gameUnit then
      if event.enemy:getHP() < event.value then
         event.unit:addSPWithPvpCorrection(self.ADD_SP_VALUE)
      end
   end
   return event.value
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "countAlive" then
      self.isOugi = true
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
   self.isOugi = false
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self.isOugi = false
   return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   self.isOugi = false
   return 1
end


class:publish();

return class;