local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グロヴォーグ", version=1.3, id=2004444});

function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 7,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:start(event)
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカルダメージ耐性"
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "氷結時に撃破でBE獲得"
      })
   }
   event.unit:setAttackDelay(5);

   return 1
end

function class:startWave(event)
   if event.unit:getIndex() == 0 and event.waves == 1 then
      self:showMessage(self.START_MESSAGE_LIST)
   end
   return 1
end

function class:update(event)
   event.unit:setReduceHitStop(2,100)
   return 1
end

function class:dead(event)
   if event.unit:getTeamUnitCondition():findConditionWithType(96) ~= nil then
      event.unit:setDeadDropSp(300);
   end
   return 1;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then
      self:showMessageAll(messageBoxList)
      return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for _,messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end



class:publish();

return class;