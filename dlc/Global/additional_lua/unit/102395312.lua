local class = summoner.Bootstrap.createUnitClass({label="樹ミラ", version=1.8, id=102395312});

function class:firstIn(event)
   event.unit:setNextAnimationName("in2")
   event.unit:setNextAnimationEffectName("empty")
   return 0;
end


class:publish();

return class;