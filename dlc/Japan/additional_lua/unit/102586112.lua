local class = summoner.Bootstrap.createUnitClass({label="クルト", version=1.3, id=102586112});

function class:takeSkill(event)
   if event.index == 3 then
      local currentHP = summoner.Utility.getUnitHealthRate(event.unit) * 100
      if currentHP > 90 then
         self:takePowerfulSkill3(event.unit)
      end
   end

   return 1
end

function class:takePowerfulSkill3(unit)
   unit:setNextAnimationName("skill3b")
   unit:setNextAnimationEffectName("2skill3b")
   
end

class:publish();

return class;