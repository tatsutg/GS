local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒アルカナ", version=2.7, id=103126512});

class.CAST_LIST = {
   cast = 50,
   cast2 = 50
}

class.BACK_LIST = {
   back = 45,
   back2 = 5,
   back3 = 30
}

function class:run(event)
   if event.spineEvent == "skill3_orbit" then
      local orbit = event.unit:addOrbitSystemWithFile("10312ef","skill3_orbit")
      orbit:setDamageRateOffset(0.5)
      orbit:setBreakRate(0.5)
      event.unit:setDamageRateOffset(0.5)
      event.unit:setBreakRate(0.5)
   end
   return 1
end

function class:takeBack(event)
   self:selectMotion(event.unit,self.BACK_LIST)
   return 1
end

function class:takeCastItem(event)
   self:selectMotion(event.unit,self.CAST_LIST)
   return 1
end

function class:selectMotion(unit,motionList)
   local motion =  summoner.Random.sampleWeighted(motionList);
   unit:setNextAnimationName(motion)
end


class:publish();

return class;