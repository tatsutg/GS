local Vector2 = summoner.import("Vector2")
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="リゴール", version=1.3, id=2012843});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

function class:setTables()
   self.drainballs = {}
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp75(status) end,
         HP = 75,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp25(status) end,
         HP = 25,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp75(status)
   if status ==  "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      -- self:showMessage(self.HP75_MESSAGE_LIST)
   end
end

function class:hp50(status)
   if status ==  "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      -- self:showMessage(self.HP50_MESSAGE_LIST)
   end
end

function class:hp25(status)
   if status ==  "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      -- self:showMessage(self.HP25_MESSAGE_LIST)
   end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "バフ説明とか",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "やっはろー",
         COLOR = Color.magenta,
         DURATION = 5,
         isPlayer = false        
      }
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self:setTriggerList()
   self:setMessageBoxList()
   self.timer = 0
   self.limit = 0.6
   self.isBallDrop = false
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:checkDrainBall(event.deltaTime)

   return 1
end

function class:checkDrainBall(deltaTime)
   if self.isBallDrop then
      if self.timer >= self.limit then
         self.isBallDrop = false
         self.setPos = true
         return 1
      end
      self.timer = self.timer + deltaTime
      self:setBeforeDrainPosition(20)
   end

   if self.setPos then
      self:setDrainPosition(24)
   end
end

function class:setDrainPosition(speed)
   for i,dTable in pairs(self.drainballs) do
      self:drainPosition(dTable.drainUnit,
         Vector2:new(dTable.drainUnit:getAnimationPositionX(),dTable.drainUnit:getPositionY()),
         Vector2:new(dTable.targetUnit:getAnimationPositionX(),dTable.targetUnit:getAnimationPositionY()),
         speed) 
         
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
         if event.unit:getIndex() == dTable.drainUnit:getIndex() then
            dTable.targetUnit:takeHeal(100000)
            dTable.drainUnit:takeAnimation(0,"empty",true)
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
      if teamUnit ~= nil and unit:getTargetUnit() ~= nil then
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


---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
      self.attackCheckFlg = true;
      return self:attackReroll(event.unit);
   end
   self.attackCheckFlg = false;
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
   self:addSP(event.unit);
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if tonumber(attackIndex) == 1 then
      unit:takeAttack(tonumber(attackIndex));
   else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
   end
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:addSP(unit)  
   unit:addSP(self.spValue);
   return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
   end

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
   return 0;
   end

   if event.index == 3 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
      self.isRage = false
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end


--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if self.TRIGGERS[index].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
   end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
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
   for i,messageBox in pairs(messageBoxList) do
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   return 1
end


class:publish();

return class;
