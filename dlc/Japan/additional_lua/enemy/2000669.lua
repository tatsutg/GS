local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.3, id=2000669});

function class:takeAttack(event)
  -- event.unit:takeSkill(2)
  return 1
end

function class:takeSkill(event)
  event.unit:setActiveSkill(2)
  return 1
end

class:publish();

return class;