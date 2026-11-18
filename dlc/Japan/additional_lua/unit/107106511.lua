local class = summoner.Bootstrap.createUnitClass({label="ボロス", version=1.3, id=107106511});

--HP減少量(割合)
class.SLICE_VALUE = 0.2
--HP減少にかかる時間(秒)
class.SLICE_SCHEDULE = 2.6

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
  self:initSlice()
  return 1
end

function class:initSlice()
  -- 最大HP
  self.FullHP = 0
  -- 減らす予定のHP量
  self.estimateHP = 0
  -- 現在のHP減少量
  self.currentSlicingHP = 0
  self.isSlicing = false
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if self.isSlicing then
    self:doSlice(event.unit,event.deltaTime)
  end
  return 1
end

-- HPが1未満にならないように減らす
function  class:doSlice(unit,deltaTime)
  if self.currentSlicingHP <= self.estimateHP then
    local sliceValue = math.ceil((deltaTime / self.SLICE_SCHEDULE) * self.estimateHP)
    self.currentSlicingHP = self.currentSlicingHP + sliceValue
    if unit:getHP() - sliceValue < 1 then
      unit:setHP(1)
    elseif self.estimateHP < self.currentSlicingHP then
      unit:setHP(unit:getHP() - (self.estimateHP - self.currentSlicingHP + sliceValue))
    else
      unit:setHP(unit:getHP() - sliceValue)
    end
    return
  end
  
  self.isSlicing = false
  self:initSlice()
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "slice" == event.spineEvent then
    self.isSlicing = true
    self.FullHP = event.unit:getCalcHPMAX()
    self.estimateHP = self.FullHP * self.SLICE_VALUE
  end
  return 1
end



class:publish();

return class;