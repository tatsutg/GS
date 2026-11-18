local Vector2 = summoner.import("Vector2")
local class = summoner.Bootstrap.createUnitClass({label="リゴール", version=1.3, id=102615512});

function class:setTables()
   self.drainballs = {}
end

function class:setBuffBox()
   self.BUFF_BOX = {
      ID = 1026155121,
      BUFF_ID = 13, -- 攻撃
      VALUE = 50,
      DURATION = 10,
      ICON = 3,
      GROUP_ID = 1006,
      PRIORITY = 50
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.timer = 0
   self.limit = 0.6
   self.isBallDrop = false

   self.gameUnit = event.unit
   self:setBuffBox()
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if self.isBallDrop then
      if self.timer >= self.limit then
         self.isBallDrop = false
         self.setPos = true
         return 1
      end
      self.timer = self.timer + event.deltaTime
      self:setBeforeDrainPosition(20)
   end

   if self.setPos then
      self:setDrainPosition(24)
   end
   return 1
end

function class:setDrainPosition(speed)
   for i,dTable in pairs(self.drainballs) do
      if dTable.drainUnit ~= nil then
         self:drainPosition(dTable.drainUnit,
            Vector2:new(dTable.drainUnit:getAnimationPositionX(),dTable.drainUnit:getPositionY()),
            Vector2:new(dTable.targetUnit:getAnimationPositionX(),dTable.targetUnit:getAnimationPositionY()),
            speed)
      end
         
   end
end

function class:setBeforeDrainPosition(speed)
   local vec = self.gameUnit:getisPlayer() and 1 or -1
   for i,dTable in pairs(self.drainballs) do
      self:drainPosition(dTable.drainUnit,
         Vector2:new(dTable.drainUnit:getAnimationPositionX(),dTable.drainUnit:getPositionY()),
         Vector2:new(dTable.drainFlightPosition.x + (75 * vec),dTable.drainUnit:getPositionY()),
         speed)
   end
end

function class:drainPosition(drain,ownVector,targetVector,speed)
   local distance = Vector2.subtracts(targetVector,ownVector)

   if speed >= math.abs(distance.magnitude) then
      ownVector = targetVector
   else
      ownVector = ownVector + (distance:normalize() * speed)
   end

   drain:setPosition(ownVector.x,ownVector.y)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "drainball" then
      self:createDrainBall(event.unit)
   end
   if event.spineEvent == "endBall" then
      for i,dTable in pairs(self.drainballs) do
         if dTable.drainUnit ~= nil and event.unit:getIndex() == dTable.drainUnit:getIndex() then
            self:execAddBuff(dTable.targetUnit,self.BUFF_BOX)
            self.setPos = false
            dTable.drainUnit:takeAnimation(0,"empty",false)
            dTable.drainUnit = nil
         end
      end
   end
   return 1
end

function class:createDrainBall(unit)
   self.timer = 0
   self.setPos = false
   self:setTables()
   self.isBallDrop = true
   for i = 0,6 do
      local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
      if teamUnit ~= nil and unit:getTargetUnit() then
         local drain = unit:addOrbitSystemWithFile("10261ef","drainball")
         math.randomseed(os.time() + i)
         local randomX = math.random(80)
         math.randomseed(os.time() + i + 10)
         local randomY = math.random(50)
         drain:takeAnimation(0,"drainball",true)
         drain:setPosition(
            unit:getTargetUnit():getAnimationPositionX(),
            unit:getTargetUnit():getAnimationPositionY())
         local tTable = {
            targetUnit = teamUnit,
            drainUnit = drain,
            drainFlightPosition = Vector2:new(drain:getAnimationPositionX() + randomX,drain:getAnimationPositionY() + randomY)
         }
         table.insert(self.drainballs,tTable)
      end
   end
end


--===================================================================================================================
-- バフ関係
--===================================================================================================================

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;

    if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
      elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
         return;
      end
    end
  
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end

end


class:publish();

return class;
