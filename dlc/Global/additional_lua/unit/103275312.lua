local class = summoner.Bootstrap.createUnitClass({label="ハルト", version=2.1, id=103275312});

function class:enableChangeBuff(event)
   if event.unit:getLevel() < 70 then return 0 end
   return 1
end

class:publish();

return class;
