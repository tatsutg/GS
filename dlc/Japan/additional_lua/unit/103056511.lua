local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="クロエ", version=2.6, id=103056511});

function class:start(event)
   self.gameUnit = event.unit;---Receiveからの呼び出し時に使う
   self.MESSAGE = self.TEXT.MESSAGE1 or "痛みは耐えきってみせます"
   return 1;
end

function class:startWave(event)
   if event.waves == 1 then
      self:addStartBuff(event.unit);
      megast.Battle:getInstance():updateConditionView();
   end
   return 1;
end

function class:addStartBuff(unit)
   unit:getTeamUnitCondition():addCondition(107116112,0,0,10000,37);
   megast.Battle:getInstance():updateConditionView();
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
   self:addStartBuff(event.unit);
   event.unit:getStartWaveOnceSkill():runSkillEffectWithID(40249801,false);
   return 1;
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
   self:phoenixExecution(event.unit);
   return 1
end

function class:phoenixExecution(unit)
   self:execShowMessage(unit)
   self:removeAllBadStatus(unit);
   if megast.Battle:getInstance():isPvp() then
       unit:setInvincibleTime(0.5);
   end
   local buff =  unit:getTeamUnitCondition():findConditionWithID(107116112);
   if buff ~= nil then
      unit:getTeamUnitCondition():removeCondition(buff);
   end
end

function class:removeAllBadStatus(unit)
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

function class:addBuff(unit,args)
   local buff  = nil;
   if args.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
   else
      buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
   end
   if args.SCRIPT ~= nil then
      buff:setScriptID(args.SCRIPT);
   end
   if args.SCRIPTVALUE1 ~= nil then
      buff:setValue1(args.SCRIPTVALUE1);
   end

end

function class:execShowMessage(unit)
   if unit:getisPlayer() then
      summoner.Utility.messageByPlayer(self.MESSAGE,5,Color.magenta);
   else
      summoner.Utility.messageByEnemy(self.MESSAGE,5,Color.magenta);
   end
end

class:publish();

return class;
