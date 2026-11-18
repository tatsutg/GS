local class = summoner.Bootstrap.createUnitClass({label="フブキ", version=1.3, id=107225212});

class.BARRIER_LIST = {
   {
      LEVEL = 1,
      VALUE = 1500
   },
   {
      LEVEL = 60,
      VALUE = 2000
   },
   {
      LEVEL = 90,
      VALUE = 2500
   }
}

-------------------------------------------------------------------------------
-- startWave
-------------------------------------------------------------------------------
function class:startWave(event)
   if event.waves == 1 then
      local level = event.unit:getLevel()
      local currentValue = 0
      for i,list in ipairs(self.BARRIER_LIST) do
         if level < list.LEVEL then
            break
         end
         currentValue = list.VALUE
      end
      event.unit:getTeamUnitCondition():addCondition(107226212,98,currentValue,9999,24,1);
      megast.Battle:getInstance():updateConditionView()
   end
   return 1
end

-------------------------------------------------------------------------------
-- run
-------------------------------------------------------------------------------
function class:run(event)

   if event.spineEvent == "shot" then
      local orbit = event.unit:addOrbitSystemWithFile("10722ef","shot")
      orbit:setDamageRateOffset(1)
      orbit:setBreakRate(1)

   end

   if event.spineEvent == "skill1_orbit_F" then
      local orbit = event.unit:addOrbitSystemWithFile("10722ef","skill1_orbit_F")
      orbit:setDamageRateOffset(1)
      orbit:setBreakRate(1)
   end

   if event.spineEvent == "splitRate" then
      event.unit:setDamageRateOffset(0.5)
      event.unit:setBreakRate(0.5)
   end

   if event.spineEvent == "skill3orbit" then
      local orbit = event.unit:addOrbitSystemWithFile("10722ef","skill3_orbit")
      orbit:setDamageRateOffset(0.5)
      orbit:setBreakRate(0.5)
   end
   return 1
end


class:publish();

return class;