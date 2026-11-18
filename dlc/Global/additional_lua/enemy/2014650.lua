local class = summoner.Bootstrap.createEnemyClass({label="パロット", version=1.3, id=2014650});

function class:start(event)
  self.gameUnit = event.unit
  return 1
end

function class:update(event)
  self:checkPlatina(event.unit,event.deltaTime)
  return 1
end

function class:checkPlatina(unit,deltaTime)

   for i = 0, 7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == 168 then
         return true
      end
   end
   self:destroy(self.gameUnit)
   megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
end

function class:receive4(args)
   self:destroy(self.gameUnit)
   return 1
end

function class:destroy(unit)
   for i = 0, 4 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil then
         localUnit:setHP(0)
      end
   end
end

class:publish();

return class;