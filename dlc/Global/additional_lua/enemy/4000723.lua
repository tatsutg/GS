local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.7, id=4000723});

class.HITSTOP = 1

function class:update(event)
  event.unit:setReduceHitStop(2,self.HITSTOP)
  return 1
end

class:publish();

return class;