local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.7, id=4000734});

class.HITSTOP = 1

function class:setMessageBoxList()
  self.MESSAGE_BOX_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "あいつをやっちゃえ！",
      COLOR = Color.green,
      DURATION = 4
    }
  }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.talked = false
  self.skilled = false
  self.gameUnit = event.unit
  self:setMessageBoxList()
  event.unit:setNeedSP(100)
  if megast.Battle:getInstance():getBattleState() == kBattleState_active then
    event.unit:addSP(event.unit:getNeedSP())
  end
  return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
  event.unit:addSP(event.unit:getNeedSP())
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setReduceHitStop(2,self.HITSTOP)
  if not self.talked then
    self.talked = true
    self:showMessage(self.MESSAGE_BOX_LIST)
  end
  if event.unit:getBurstState() == kBurstState_active then
    self.skilled = true
  end

  if event.unit:getBurstState() ~= kBurstState_active and self.skilled then
    self.skilled = false
    event.unit:setHP(0)
  end
  return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
-- function class:takeAttack(event)
--   if not megast.Battle:getInstance():isHost() and not self.checkedSkill then
--     return 0
--   end

--   if megast.Battle:getInstance():isHost() and not self.skilled then
--     self.checkedSkill = true
--     event.unit:takeSkill(2)
--     event.unit:setBurstState(kBurstState_active)
--     megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0)
--   end
--   return 0
-- end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
-- function class:takeSkill(event)
--   -- if not megast.Battle:getInstance():isHost() and not self.checkedSkill then
--   --   return 0
--   -- end

--   -- if megast.Battle:getInstance():isHost() and not self.checkedSkill then
--   self.checkedSkill = true
--   -- event.unit:takeSkill(2)
--   -- event.unit:setBurstState(kBurstState_active)
--   -- megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0)
--   --   return 0
--   -- end
--   return 1
-- end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
-- function class:receive1(args)
--   self.checkedSkill = true
--   self.gameUnit:takeSkill(2)
--   self.gameUnit:setBurstState(kBurstState_active)
--   return 1
-- end

-- function class:receive2(args)
--   self.checkedSkill = true
--   self.gameUnit:takeSkill(2)
--   self.gameUnit:setBurstState(kBurstState_active)
--   return 1
-- end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
  if index == nil then 
    self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
    return
  end
  self:execShowMessage(messageBoxList[index])
end

function class:showMessageRange(messageBoxList,start,finish)
  for i = start,finish do
    self:execShowMessage(messageBoxList[i])
  end
end

function class:execShowMessage(messageBox)
  summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end


class:publish();

return class;