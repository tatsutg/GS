local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ミキュオン", version=1.3, id=1000071211});

class.SPEED = 10
class.LIMIT_X = 300
class.ATTACK_INTERVAL = 5
class.MAX_ADD_HASTE_VALUE = 2

-- 速度上昇(割合)
function class:setupHaste()
  self.HASTE_LIST = {
    [0] = {
      timing = 10,
      value = 1.2,
      used = false
    },
    [1] = {
      timing = 30,
      value = 1.5,
      used = false
    }
  }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  event.unit:getSkeleton():setScale(2.2);
  event.unit:setHPBarHeightOffset(10000);
  event.unit.m_IgnoreHitStopTime = 999999;
  event.unit:setSPGainValue(0);
  event.unit:setSkillInvocationWeight(0);
  event.unit:setAttackDelay(999999);
  event.unit:setAutoZoder(false);
  event.unit:setLocalZOrder(9000 + event.unit:getIndex());
  
  self.attackTimer = 0
  self.currentTime = 0
  self.posX = 0
  self.haste_index = 0
  self.speed_mod = 1
  self:calcHP(event.unit);
  self:setupHaste()
  return 1
end

function class:calcHP(unit)
  local lv = unit:getLevel();

  local HP = math.pow(10,lv/20) * 10000;
  unit:setBaseHP(HP);
  unit:setHP(HP);  
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
  if self:isStop(event.unit) then
    return 0
  end

  event.unit.m_IgnoreHitStopTime = 999999;
  event.unit:takeFront();
  event.unit:setUnitState(kUnitState_none);
  return 0;
end

function class:isStop(unit)
  local stun = unit:getTeamUnitCondition():findConditionValue(89);
  local para = unit:getTeamUnitCondition():findConditionValue(91);
  local freeze = unit:getTeamUnitCondition():findConditionValue(96);

  if stun > 0 or para > 0 or freeze > 0 then
    return true;
  end
  return false
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setLocalZOrder(9000 + event.unit:getIndex());
  event.unit:setSize(3);

  --行動不能時はカウントを進めない
  if event.unit:getUnitState() == kUnitState_damage or self:isStop(event.unit) then
    event.unit:setPositionX(self.posX);
    self:elapsed(event.unit,event.deltaTime)
    return 1;
  end

  self:attackManager(event)
  self:positionManager(event.unit,event.deltaTime)
  return 1
end

function class:attackManager(event)
  if self.attackTimer < self.ATTACK_INTERVAL then
    self.attackTimer = self.attackTimer + event.deltaTime
  else
    event.unit:takeAttack(1)
    event.unit:setActiveSkill(1)
    self.attackTimer = self.attackTimer - self.ATTACK_INTERVAL
  end
end

function class:positionManager(unit,deltaTime)
  --移動の処理
  if self.posX == 0 then
    self.posX = unit:getPositionX();
  end
  if unit:getUnitState() == kUnitState_none and self.posX < self.LIMIT_X then
    self.posX = self.posX + self.SPEED * deltaTime * self.speed_mod;
  end

  unit:setPositionX(self.posX)
end

function class:elapsed(unit,deltaTime)
  self.currentTime = self.currentTime + deltaTime

  if table.maxn(self.HASTE_LIST) < self.haste_index then
    return
  end

  if self.HASTE_LIST[self.haste_index].timing <= self.currentTime and 
    not self.HASTE_LIST[self.haste_index].used then
    
    local add_haste = self.MAX_ADD_HASTE_VALUE * (unit:getLevel() / 100)

    self.speed_mod = self.HASTE_LIST[self.haste_index].value + add_haste
    self.HASTE_LIST[self.haste_index].used = true
    self.haste_index = self.haste_index + 1

  end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  event.unit:setSize(1);
  return event.value > 9999 and 9999 or event.value;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
  self.posX = self.posX - 1
  return 1
end


class:publish();

return class;