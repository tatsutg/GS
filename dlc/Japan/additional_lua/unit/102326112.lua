local class = summoner.Bootstrap.createUnitClass({label="イフリート", version=1.3, id=102326112});

class.BUFF_BOX = {
  [0] = {
    ID = 10001,
    BUFF_ID = 97,
    VALUE = 100,
    TIME = 100,
    ICON_ID = 87
  }
}

function class:run(event)
  if "calm" == event.spineEvent then
    -- 鎮火
    self:execRemoveCondition(event.unit,self.BUFF_BOX[0].BUFF_ID)
  end

  return 1
end

-- バフ
function class:evexAddCondition(unit,buffBox)
  if buffBox.EFFECT_ID ~= nil then
    unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.TIME,buffBox.ICON_ID,buffBox.EFFECT_ID)
  else
    unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.TIME,buffBox.ICON_ID)
  end

end

-- バフ削除
function class:execRemoveCondition(unit,buffId)
  while unit:getTeamUnitCondition():findConditionWithType(buffId) ~= nil do
    unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithType(buffId))
  end
end


class:publish();

return class;