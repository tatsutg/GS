local class = summoner.Bootstrap.createUnitClass({label="ロキシー", version=1.9, id=107526212});


function class:takeSkill(event)
   if event.index == 3 then
      local rand  = math.random(100)
      if rand < 97 then
         event.unit:setNextAnimationName("skill3_2")
      end
   end
   return 1
end


class:publish();

return class;