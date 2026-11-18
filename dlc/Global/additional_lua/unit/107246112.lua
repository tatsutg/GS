local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ヒメ", version=1.8, id=107246112});

class.IN_MOTIONS = {
   in1 = 65,
   in2 = 5,
   in3 = 30
}

-------------------------------------------------------------------------------
-- start
-------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit;--Receveからの呼び出し時に使う
   self.phoenixFlag = false;
   self.takedIn = false
   return 1
end

-------------------------------------------------------------------------------
-- startWave
-------------------------------------------------------------------------------
function class:startWave(event)
  if event.unit:getLevel() < 90 then
      return 1;
  end
  self:addStartBuff(event.unit);
  megast.Battle:getInstance():updateConditionView();
  return 1;
end

function class:addStartBuff(unit)
    if self:getPhoenixFlag(unit) then
        return;
    end
   unit:getTeamUnitCondition():addCondition(107116112,0,0,10000,194);
   self.phoenixFlag = true;
   megast.Battle:getInstance():updateConditionView();
end

function class:getPhoenixFlag(unit)
   local flg = unit:getParameter("phoenixTimer");
   if flg ~= nil and flg ~= "" and flg ~= "false" then
      return true;
   end
   return false;
end

-------------------------------------------------------------------------------
-- dead
-------------------------------------------------------------------------------
function class:dead(event)
    if self:getPhoenixFlag(event.unit) then
        return 1;
    end
   if self.phoenixFlag and self:isControllTarget(event.unit) then
      self.phoenixFlag = false;
      self:phoenixExcution(event.unit);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
      return 0;
   end
   return 1;
end

function class:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end
end

function class:phoenixExcution(unit)
   unit:setHP(unit:getCalcHPMAX()/2);
   unit:takeAnimation(0,"resurrection",false)
   self:removeAllBadstatus(unit);
   self:execRemoveCondition(unit,107116112)
   self:setPhoenixFlag(unit);
   if unit:getisPlayer() then
      summoner.Utility.messageByPlayer(self.TEXT.mess1,5,summoner.Color:new(255,178,60));
   else
      summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color:new(255,178,60));
   end
end

function class:removeAllBadstatus(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
        end
    end
end

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end  
end

function class:setPhoenixFlag(unit)
   unit:setParameter("phoenixTimer","true"); 
end

function class:receive2(args)
   self:phoenixExcution(self.gameUnit);
   return 1;
end

-------------------------------------------------------------------------------
-- firstIn
-------------------------------------------------------------------------------
function class:firstIn(event)
   if not self.takedIn then
      self:selectIn(event.unit)
   end
   return 1
end

-------------------------------------------------------------------------------
-- takeIn
-------------------------------------------------------------------------------
function class:takeIn(event)
   if not self.takedIn then
      self:selectIn(event.unit)
   end
   return 1
end

function class:selectIn(unit)
   if megast.Battle:getInstance():isHost() then
      self.takedIn = true
      local motion =  summoner.Random.sampleWeighted(self.IN_MOTIONS);
      if motion == "in1" then
         motion = "in"
      end
      unit:setNextAnimationName(motion)
   end
   return 0
end



class:publish();

return class;