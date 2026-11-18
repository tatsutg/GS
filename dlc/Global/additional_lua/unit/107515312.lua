local class = summoner.Bootstrap.createUnitClass({label="ルーデウス", version=1.9, id=107515312});

class.range = {
   left = -200,
   right = 200,
   up = 50,
   down = -50
}


function class:start(event)
   self.enemyList = {}
   self.swampX = 0
   self.swampY = 0
   self.total = event.unit:getParameter("total") == "" and 0 or tonumber(event.unit:getParameter("total"))
   return 1
end

function class:startWave(event)
   self.enemyList = {}
   self.isSwamp = false
   return 1
end

function class:update(event)
   if self.isSwamp then
      for _,list in ipairs(self.enemyList) do
         if list.teamUnit ~= nil and list.teamUnit:getParameter("total") == list.total and list.orbit ~= nil then
            local x = list.teamUnit:getPositionX() + list.teamUnit:getSkeleton():getBoneWorldPositionX("root")
            local y = list.teamUnit:getPositionY() + list.teamUnit:getSkeleton():getBoneWorldPositionY("root")
            list.orbit:setPosition(x,y)
         end
      end
   end
   return 1
end

function class:attackElementRate(event)
   local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
   if skillType ~= 1 then
      return event.value;
   end
   local el = event.enemy:getElementType();
   if el == kElementType_Earth then
      event.value = megast.Battle:getInstance():getElementalRate(1,3)
   end
   return event.value;
end

function class:run(event)
   if event.spineEvent == "swamp" then
      local target = event.unit:getTargetUnit()
      if target ~= nil then
         self:setSwamp(event.unit,target)
      end
   end
   if event.spineEvent == "skill2Shot" then
      self.enemyList = {}
      local hit = event.unit:addOrbitSystem("hit_skill2")
      hit:setDamageRateOffset(0.5)
      hit:setBreakRate(0.5)
      hit:setPosition(self.swampX,self.swampY)
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(not event.unit:getisPlayer()):getTeamUnit(i);
         if teamUnit ~= nil then
            self.isSwamp = true
            local x = teamUnit:getPositionX() + teamUnit:getSkeleton():getBoneWorldPositionX("MAIN")
            local y = teamUnit:getPositionY() + teamUnit:getSkeleton():getBoneWorldPositionY("MAIN")
            if self:checkPosition(x,y) then
               local orbit
               if teamUnit:getSize() == 3 then
                  orbit = event.unit:addOrbitSystem("earthcuffs_large",0)
               else
                  orbit = event.unit:addOrbitSystem("earthcuffs_small",0)
               end
               orbit:setPosition(x,y)
               self.total = self.total + 1
               event.unit:setParameter("total",self.total)
               teamUnit:setParameter("total",self.total)
               table.insert(self.enemyList,{orbit = orbit,teamUnit = teamUnit,total = self.total})
            end
         end
      end
   end
   if event.spineEvent == "endShot" then
      self.isSwamp = false
   end
   return 1
end

function class:setSwamp(unit,target)
   self.enemyList = {}
   local swamp = unit:addOrbitSystem("swanp")
   self.swampX = target:getPositionX() + target:getSkeleton():getBoneWorldPositionX("root")
   self.swampY = target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("root")
   swamp:setDamageRateOffset(0.5)
   swamp:setBreakRate(0.5)
   swamp:setPosition(self.swampX, self.swampY)
end

function class:checkPosition(x,y)
   if self.swampX + self.range.left < x and x < self.swampX + self.range.right and self.swampY + self.range.down < y and y < self.swampY + self.range.up then
      return true
   end
   return false
end


class:publish();

return class;