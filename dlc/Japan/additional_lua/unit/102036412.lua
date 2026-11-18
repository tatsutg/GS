local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=102036412});

class.BUFF_BOX_LIST = {
  [0] = {
    ID = 1001,
    BUFF_ID = 89,
    VALUE = 10,
    TIME = 10,
    ICON_ID = 48
  }
}

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.isBreak = false
  
  self.currentEffectName = ""
  self.effectName1 = "treasure_chest_EF1"
  self.effectName2 = "treasure_chest_EF2"

  self.currentTime = 0
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if self.isBreak then
    self.currentTime = self.currentTime + event.deltaTime
  end
  if self.currentTime > 3 then
    self.isBreak = false
    self.currentTime = 0
  end
  return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  --[[
  if "break" == event.spineEvent then
    self.isBreak = true
  end
  ]]--
  return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
  return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if 2 == event.index then
    self.currentEffectName = self.effectName1
  end

  if 3 == event.index then
    self.currentEffectName = self.effectName2
  end

  return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
  --[[
  if self.isBreak and event.enemy:getTeamUnitCondition():findConditionWithType(135) ~= nil then
    local breakEffect = event.unit:addOrbitSystemWithFile("10203ef",self.currentEffectName)

    if event.enemy:getSize() == 3 then
      breakEffect:setScale(2,2)
    end

    breakEffect:setPosition(event.enemy:getAnimationPositionX(),event.enemy:getAnimationPositionY())
    self:execRemoveCondition(event.enemy,135)
  end
  ]]--

  return event.value
end

-- バフ削除
function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithType(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithType(buffId))
      unit:resumeUnit()
    end  
end

class:publish();

return class;