local class = summoner.Bootstrap.createUnitClass({label="ヴァレンティア", version=1.3, id=102386411});

-- 最大パーティ数
class.MAX_PARTY_MEMBER = 3
-- 基礎回復量（0~1の割合）
class.BASE_HEAL_PROP = 0.15

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.myUnit = event.unit
  self.targetUnit = event.unit;
  return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "healValentia" == event.spineEvent then
    self:selectTargetUnit(event.unit)
    self:execHeal()
  end
  return 1
end

-- 回復
function class:execHeal()
  local rate = (100 + self.targetUnit:getTeamUnitCondition():findConditionValue(115) 
      + self.targetUnit:getTeamUnitCondition():findConditionValue(110))/100
  local healValue = (self.targetUnit:getCalcHPMAX() * self.BASE_HEAL_PROP) * rate
  self.targetUnit:takeHeal(healValue,self.myUnit)
end

-- 回復対象設定
function class:selectTargetUnit(unit)
  local health = 100
  local currentUnitPosition = 0
  for i = 0,self.MAX_PARTY_MEMBER do
    local localUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
    if localUnit ~= nil then
      local targetHP = self:currentHP(localUnit)
       if health > targetHP then
         self.targetUnit = localUnit
         health = targetHP
         currentUnitPosition = i
      end
    end
  end

  -- 全員のHPが満タンの時は自分自身を指定する
  if health == 100 then
    currentUnitPosition = self.myUnit:getIndex()
    self.targetUnit = self.myUnit
  end
  return currentUnitPosition
end

function class:currentHP(unit)
  return (unit:getHP() / unit:getCalcHPMAX()) * 100
end

function class:isController(unit)
  if unit ~= nil then
   return unit:isMyunit() or self:isEnemyHost(unit)
 end
end

function class:isEnemyHost(unit)
  return not unit:getisPlayer() and megast.Battle:getInstance():isHost()
end



class:publish();

return class;