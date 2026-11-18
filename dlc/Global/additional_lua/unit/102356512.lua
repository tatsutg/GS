local class = summoner.Bootstrap.createUnitClass({label="ラキ", version=1.3, id=102006112});


class.ADD_SP_VALUE = 2
---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.isSkill3 = false
  return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "endSkillEffect" == event.spineEvent then
    self.isSkill3 = false
  end
  return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
  if self.isSkill3 then
    event.unit:addSPWithPvpCorrection(self.ADD_SP_VALUE)
  end
  return event.value
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
  self.isSkill3 = false
  return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  self.isSkill3 = false
  if 3 == event.index then
    self.isSkill3 = true
  end
  return 1
end


class:publish();

return class;
