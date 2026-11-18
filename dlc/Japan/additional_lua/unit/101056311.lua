local Vector2 = summoner.import("Vector2")
local class = summoner.Bootstrap.createUnitClass({label="フェン", version=1.3, id=101056311});

-- 滞空位置
class.DISTANCE_X = 50
class.DISTANCE_Y = 80
-- 初期位置  
class.DEFAULT_X = 600
class.DEFAULT_Y = 0
-- 最大パーティ数(0-3 or 0-6)
class.MAX_PARTY_MEMBER = 3
-- 各アニメーション
class.BIRD_IN = "2-birdIn"
class.BIRD_IDLE = "2-birdIdle"
class.BIRD_EX = "2-birdEx"
-- 移動速度
class.SPEED = 10
-- 基礎回復量（0~1の割合）
class.BASE_HEAL_PROP = 0.05

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)

  self.myUnit = event.unit
  self.isRestWings = false
  self.isHealing = false
  self.isWalking = false
  self.setScale = 1

  --　敵で出てきた場合
  if not event.unit:getisPlayer() then
    self.DISTANCE_X = self.DISTANCE_X * -1
    self.DEFAULT_X = self.DEFAULT_X * -1
    self.setScale = -1
    self.MAX_PARTY_MEMBER = 6
  end

  self:createBirdInstance(event.unit)

  return 1
end

-- 鳥の初期化
function class:createBirdInstance(unit)
  self.birdObject = {
    targetUnit = self.myUnit,
    instance = self.myUnit:addOrbitSystemWithFile("10105ef",self.BIRD_IN),
    pos = Vector2:new(self.DEFAULT_X,self.DEFAULT_Y)    
  }
  self.birdObject.instance:setPosition(self.DEFAULT_X,self.DEFAULT_Y)
  self.birdObject.instance:getSkeleton():setScaleX(self.setScale)
  self:sendAnimation(self.birdObject.instane,self.BIRD_IN)
end

---------------------------------------------------------------------------------
-- update 
---------------------------------------------------------------------------------
function class:update(event)
  self:setBirdPosition()
  return 1
end

-- 鳥帰宅
function class:goHome()
  self.isRestWings = false
  self.isHealing = false
  self.birdObject.targetUnit = self.myUnit
end

-- 移動
function class:setBirdPosition()
  if self.birdObject ~= nil then
    local goalX = self.birdObject.targetUnit:getAnimationPositionX() + self.DISTANCE_X
    local goalY = self.birdObject.targetUnit:getAnimationPositionY() + self.DISTANCE_Y
    local goal = Vector2:new(goalX,goalY)
    local distance = Vector2.subtracts(goal,self.birdObject.pos)
   
    if self.SPEED >= math.abs(distance.magnitude) then
      self.birdObject.pos = self.birdObject.pos + distance
      self:execHealing()
      self:confirmSurvival()
    else
      self.birdObject.pos = self.birdObject.pos + (distance:normalize() * self.SPEED)   
    end
    self.birdObject.instance:setPosition(self.birdObject.pos.x,self.birdObject.pos.y) 

  end
end

-- 回復アニメに移行
function class:execHealing()
  if self.isRestWings then
    self.isRestWings = false
    if not self.isHealing then
      self.isHealing = true
      self:sendAnimation(self.birdObject.instance,self.BIRD_EX)
    end
  end
end

-- 回復対象ユニットの生存確認
function class:confirmSurvival()
  if self.isHealing then
    if self.birdObject.targetUnit:getHP() <= 0 then
      self.birdObject.targetUnit = self.myUnit
    end
  end
end

---------------------------------------------------------------------------------
-- run 
---------------------------------------------------------------------------------
function class:run(event)
  if "birdStateEnd" == event.spineEvent then
    self:sendAnimation(self.birdObject.instance,self.BIRD_IDLE)
    self:goHome()
  end

  if "birdEX" == event.spineEvent then
    local rate = (100 + self.birdObject.targetUnit:getTeamUnitCondition():findConditionValue(115) 
      + self.birdObject.targetUnit:getTeamUnitCondition():findConditionValue(110))/100
    local healValue = (self.birdObject.targetUnit:getCalcHPMAX() * self.BASE_HEAL_PROP) * rate
    self.birdObject.targetUnit:takeHeal(healValue,event.unit)
  end

  return 1
end

-- アニメーションの変更
function class:sendAnimation(unit,animationName)
  if unit ~= nil then
    unit:takeAnimation(0,animationName,true)
  end
end

-- 行き先設定
function class:selectTargetUnit(unit)
  local health = 100
  local currentUnitPosition = 0
  for i = 0,self.MAX_PARTY_MEMBER do
    local unit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
    if unit ~= nil then
      local targetHP = self:currentHP(unit)
       if health > targetHP then
         self.birdObject.targetUnit = unit
         health = targetHP
         currentUnitPosition = i
      end
    end
  end

  -- 全員のHPが満タンの時は自分自身を指定する
  if health == 100 then
    currentUnitPosition = self.myUnit:getIndex()
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

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if 1 == event.index then
    if self:isController(event.unit) then
      self.isRestWings = true
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self:selectTargetUnit(event.unit))
    end
  end

  return 1
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive1(arg)
  self.isRestWings = true
  self.birdObject.targetUnit = megast.Battle:getInstance():getTeam(self.myUnit:getisPlayer()):getTeamUnit(arg.arg)
  return 1
end

class:publish();

return class;