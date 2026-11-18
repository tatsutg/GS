local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ヒメ", version=1.8, id=107245112});

class.IN_MOTIONS = {
   in1 = 65,
   in2 = 5,
   in3 = 30
}

-------------------------------------------------------------------------------
-- start
-------------------------------------------------------------------------------
function class:start(event)
   self.takedIn = false
   return 1
end

-------------------------------------------------------------------------------
-- firstIn
-------------------------------------------------------------------------------
function class:firstIn(event)
   if not self.takedIn then
      self:selectIn(event.unit)
   end
   return 1
end

-------------------------------------------------------------------------------
-- takeIn
-------------------------------------------------------------------------------
function class:takeIn(event)
   if not self.takedIn then
      self:selectIn(event.unit)
   end
   return 1
end

function class:selectIn(unit)
   if megast.Battle:getInstance():isHost() then
      self.takedIn = true
      local motion =  summoner.Random.sampleWeighted(self.IN_MOTIONS);
      if motion == "in1" then
         motion = "in"
      end
      unit:setNextAnimationName(motion)
   end
   return 0
end


class:publish();

return class;