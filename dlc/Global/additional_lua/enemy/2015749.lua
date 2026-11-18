local class = summoner.Bootstrap.createEnemyClass({label="アデル", version=1.3, id=2015749});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   event.unit:setAttackDelay(999999);
   event.unit:setInvincibleTime(999999)
   event.unit:setRange_Max(300)
   -- self:showMessage(self.START_MESSAGE_LIST)
   self.isFirst = false
   self.isEnd = false
   return 1
end

---------------------------------------------------------------------------------
-- update 
---------------------------------------------------------------------------------
function class:update(event)
   if not self.isFirst then
      self.isFirst = true
      return 1
   end
   if not self:findRaki(event.unit) and not self.isEnd and megast.Battle:getInstance():isHost() then
      self.isEnd = false
      self.gameUnit:setHP(0)
      -- megast.Battle:getInstance():setBattleState(kBattleState_none);
      -- megast.Battle:getInstance():waveEnd(true);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0)
   end

   return 1
end

function class:receive1(args)
      self.gameUnit:setHP(0)
   -- megast.Battle:getInstance():setBattleState(kBattleState_none);
   -- megast.Battle:getInstance():waveEnd(true);
   return 1
end

function class:findRaki(unit)
   for i = 0,7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == 235 then
         -- unit:takeHeal(100)
         return true
      end
   end
   return false
end

function class:takeAttack(event)
   event.unit:takeIdle()
   return 0
end

class:publish();

return class;