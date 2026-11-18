local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="パルラミシア", version=1.3, id=102315212});

class.INVINCIBLE_TIME = 2.5

class.COUNTER_NM = "skill2counter"
class.CANCEL_NM = "skill2Failed"

class.COUNTER_EF = "1skill2counter"
class.CANCEL_EF = "1skill2Failed"

-- ブレイクポイント減少(割合)
class.REDUCE_BREAKPOINT_RATE = 0.85

-- ブレイクポイント減少(固定値/レイド)
class.REDUCE_BREAKPOINT_CONSTANT = 5000

-- ブレイクポイント減少(固定値/クロスバトル)
class.REDUCE_BREAKPOINT_CONSTANT_CROSS = 5000

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
  self.myUnit = event.unit
  self.isCounterSuccess = false
  self.isCounter = false
  return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "counter" == event.spineEvent and self:isControll(event.unit) then
    self.isCounter = true
  end
  if "cancel" == event.spineEvent and self:isControll(event.unit) then
    self.isCounter = false
    self:cancelImpl(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1)
  end
  return 1
end

function class:isControll(unit)
  return unit:isMyunit() or self:isEnemyHost(unit)
end

function class:isEnemyHost(unit)
  return not unit:getisPlayer() and megast.Battle:getInstance():isHost()
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
  self.isCounter = false
  return 1 
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
  if self.isCounterSuccess then
    self:reduceBreakPoint(event.enemy, event.unit)
  end
  return event.value
end

function class:reduceBreakPoint(unit, caster)
  if megast.Battle:getInstance():isRaid() then
    --megast.Battle:getInstance():recAddBreakPoint(caster, unit, unit:getBreakPoint() - (unit:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT));
    --unit:setBreakPoint(unit:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT)
    unit:fixedBreakDamage(self.REDUCE_BREAKPOINT_CONSTANT,caster)
    RaidControl:get():addBreakPool(self.REDUCE_BREAKPOINT_CONSTANT);
    return
  elseif megast.Battle:getInstance():isCrossBattle() then
    --megast.Battle:getInstance():recAddBreakPoint(caster, unit, unit:getBreakPoint() - (unit:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT_CROSS));
    --unit:setBreakPoint(unit:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS)
    unit:fixedBreakDamage(self.REDUCE_BREAKPOINT_CONSTANT_CROSS,caster)
    return
  end
  --megast.Battle:getInstance():recAddBreakPoint(caster, unit, unit:getBreakPoint() - (unit:getBreakPoint() * self.REDUCE_BREAKPOINT_RATE));
  --unit:setBreakPoint(unit:getBreakPoint() * self.REDUCE_BREAKPOINT_RATE)
  unit:fixedBreakDamage(unit:getBreakPoint() * 0.15,caster)
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  if self.isCounter and self:isControll(event.unit) then
    self.isCounter = false
    self.isCounterSuccess = true
    self:counterImpl(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1)
    return 0
  end
  return event.value
end

function class:counterImpl(unit)
  unit:setInvincibleTime(self.INVINCIBLE_TIME)
  unit:setAnimation(0,self.COUNTER_NM,false)
  unit:takeAnimationEffect(0,self.COUNTER_EF,false)
end

function class:cancelImpl(unit)
  unit:setInvincibleTime(self.INVINCIBLE_TIME)
  unit:setAnimation(0,self.CANCEL_NM,false)
  unit:takeAnimationEffect(0,self.CANCEL_EF,false)
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
  self.isCounterSuccess = false
  return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  self.isCounterSuccess = false
  return 1
end

---------------------------------------------------------------------------------
-- recieve
---------------------------------------------------------------------------------
function class:receive1(args)
  self:counterImpl(self.myUnit)
  return 1
end

function class:receive2(args)
  self:cancelImpl(self.myUnit)
  return 1
end


class:publish();

return class;
