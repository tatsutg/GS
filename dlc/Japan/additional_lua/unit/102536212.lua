local class = summoner.Bootstrap.createUnitClass({label="水メリア", version=1.3, id=102536212});

--------[[table]]--------
function class:refreshTable()
   self.enemies = {}
end

--------[[特殊行動]]--------
function class:execGrayScale(unit)
   if self.isStop and unit:getParentTeamUnit() == nil then
      unit:takeGrayScale(0.01)
      table.insert(self.enemies,unit:getIndex())
   end
end

function class:removeGrayScale(unit)
   if not self.isStop then
      return 
   end

   for i = 1,table.maxn(self.enemies) do
      local u = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(self.enemies[i],true);
      if u ~= nil then
         u:takeGrayScale(0.99)
      end
   end
   self.isStop = false
   self:refreshTable()
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.isStop = false
   self:refreshTable()
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "theWorld" then self.isStop = true end
   if event.spineEvent == "worldEnd" then self:removeGrayScale(event.unit) end
   return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   self:removeGrayScale(event.unit)
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   self:removeGrayScale(event.unit)
   return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   self:execGrayScale(event.enemy)
   return event.value
end


class:publish();

return class;