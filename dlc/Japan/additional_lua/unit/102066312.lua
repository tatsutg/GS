local class = summoner.Bootstrap.createUnitClass({label="ノルン", version=2.7, id=102066312});

-- 真奥義後のバフ時間
class.OVER_BUFF_TIME = 30

-- バフ中のアニメーション
class.OVER_ANIMATIONS = {
  attack1 = "attack1-over",
  back = "back-over",
  cast = "cast-over",
  damage = "damage-over",
  front = "front-over",
  idle = "idle-over",
  skill1 = "skill1-over",
  skill2 = "skill2-over"
}

-- 真奥義バフ
function class:setBuffBox()
  self.BUFF_BOX = {
    ID = 10206,
    BUFF_ID = 10,
    VALUE = 3,
    TIME = 20,
    ICON_ID = 36,
    GROUP_ID = 1034,
    PRIORITY = 60
  }
end


---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
  self.isOver = false
  self.overTimer = 0
  self.aura = nil
  self.gameUnit = event.unit
  self:setBuffBox()
  return 1
end

function class:sendAnimation(unit,animationName)
  if self.isOver then
    -- unit:takeAnimation(0,self.OVER_ANIMATIONS[animationName],true)
    unit:setNextAnimationName(self.OVER_ANIMATIONS[animationName])
  end
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  if self.isOver then
    if self.overTimer < self.OVER_BUFF_TIME then
      self.overTimer = self.overTimer + event.deltaTime
      self:auraPosition(event.unit)
    else
      self.overTimer = 0
      self.isOver = false
      self:auraEnd(event.unit)
    end
  end
  return 1
end

function class:auraPosition(unit)
  if self.aura == nil then
    return
  end

  local vec = unit:getisPlayer() and 1 or -1
  local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
  local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN") - 65;

  self.aura:setPosition(targetx,targety);
  self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
  self.aura:setZOrder(unit:getZOrder() + 1)
  -- self.aura:setAutoZOrder(true);
end

function class:auraEnd(unit)
  self.aura:takeAnimation(0,"empty",false);
  self.aura = nil;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "addBuffNorn" == event.spineEvent then
    self:addBuffAll(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
  end
  return 1
end

function class:addBuffAll(unit)
  for i = 0,7 do
    local teamUnit = unit:getTeam():getTeamUnit(i,true);
    if teamUnit ~= nil then
      self:addBuff(teamUnit);
    end
  end
end

function class:addBuff(unit)
  local cond = unit:getTeamUnitCondition():findConditionWithGroupID(self.BUFF_BOX.GROUP_ID);
  
  if cond ~= nil and cond:getPriority() <= self.BUFF_BOX.PRIORITY then
    unit:getTeamUnitCondition():removeCondition(cond);
    local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_BOX.ID,self.BUFF_BOX.BUFF_ID,self.BUFF_BOX.VALUE,self.BUFF_BOX.TIME,self.BUFF_BOX.ICON_ID);
    newCond:setGroupID(self.BUFF_BOX.GROUP_ID);
    newCond:setPriority(self.BUFF_BOX.PRIORITY);
  elseif cond == nil then
    local newCond = unit:getTeamUnitCondition():addCondition(self.BUFF_BOX.ID,self.BUFF_BOX.BUFF_ID,self.BUFF_BOX.VALUE,self.BUFF_BOX.TIME,self.BUFF_BOX.ICON_ID);
    newCond:setGroupID(self.BUFF_BOX.GROUP_ID);
    newCond:setPriority(self.BUFF_BOX.PRIORITY);
  end

end



---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
  return self:sendAnimation(event.unit,"damage")
end

---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
  return self:sendAnimation(event.unit,"front")
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
  return self:sendAnimation(event.unit,"back")
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCastItem(event)
  return self:sendAnimation(event.unit,"cast")
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function  class:takeIdle(event)
  return self:sendAnimation(event.unit,"idle")
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
  return self:sendAnimation(event.unit,"attack1")
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if 1 == event.index then
    self:sendAnimation(event.unit,"skill1")
  end
  if 2 == event.index then
    self:sendAnimation(event.unit,"skill2")
  end
  if 3 == event.index then
    self.isOver = true
    self.overTimer = 0
    self:auraCreate(event.unit)
  end

  return 1
end

function class:auraCreate(unit)
  if self.aura ~= nil then
    return
  end

  self.aura = unit:addOrbitSystem("aura_PTE");
  self.aura:setOrbitType(4)
  self.aura:takeAnimation(0,"aura_PTE",true);
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------


class:publish();

return class;