local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="クロエ", version=1.3, id=103056511});

function class:start(event)
   self.gameUnit = event.unit;--Receveからの呼び出し時に使う
   self.phoenixFlag = false;

   self.damage = 0
   self.spGainTime = math.floor(event.unit:getCalcHPMAX() * 0.1)

   self.MESSAGE = self.TEXT.MESSAGE1 or "痛みは耐えきってみせます"
   return 1;
end

function class:startWave(event)
   self:addStartBuff(event.unit);
   megast.Battle:getInstance():updateConditionView();
   if event.waves == 1 and not megast.Battle:getInstance():isPvp() then
        self:additinalCheck(event.unit);
    end
   return 1;
end

function class:additinalCheck(unit)
    for i = 0 , 6 do
        teamunit = unit:getTeam():getTeamUnit(i);
        if teamunit ~= nil then
            if teamunit:getBaseID3() == 304 then
                unit:addSPWithPvpCorrection(100);
                return;
            end
        end
    end
end

function class:dead(event)
   if self:getPhoenixFlag(event.unit) then
      return 1;
   end
   if self.phoenixFlag and self:isControllTarget(event.unit) then
      self.phoenixFlag = false;
      self.phoenixTimer = 0;
      self:phoenixExcution(event.unit);
      if not megast.Battle:getInstance():isPvp() then
          megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
	  end
      return 0;
   end
   return 1;
end



--====================================================================================================================
--

function class:addStartBuff(unit)
   if self:getPhoenixFlag(unit) then
      return;
   end
   unit:getTeamUnitCondition():addCondition(107116112,0,0,10000,37);
   self.phoenixFlag = true;
   megast.Battle:getInstance():updateConditionView();
end


function class:setPhoenixFlag(unit)
   unit:setParameter("phoenixTimerSugimoto","true");
end

function class:getPhoenixFlag(unit)
   local flg = unit:getParameter("phoenixTimerSugimoto");
   if flg ~= nil and flg ~= "" and flg ~= "false" then
      return true;
   end
   return false;
end

function class:phoenixExcution(unit)
   self:execShowMessage(unit)
   unit:setHP(unit:getCalcHPMAX());
   self:removeAllBadstatus(unit);
   if megast.Battle:getInstance():isPvp() then
       unit:setInvincibleTime(0.5);
   end

   --unit:addSP(200);
   --unit:playVoice("VOICE_FULLARTS_RANK6");
   --if unit:getisPlayer() then
   --   summoner.Utility.messageByPlayer(self.TEXT.mess1,5,summoner.Color.red);
   --else
   --   summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
   --end
   local buff =  unit:getTeamUnitCondition():findConditionWithID(107116112);
   if buff ~= nil then
      unit:getTeamUnitCondition():removeCondition(buff);
   end
   self:setPhoenixFlag(unit);
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

--====================================================================================================================

function class:isControllTarget(unit)
   if unit:isMyunit() then
      return true;
   end
   if megast.Battle:getInstance():isPvp() then
      return true;
   end
   if not unit:getisPlayer() then
      return megast.Battle:getInstance():isHost();
   end

end


function class:addBuffs(unit,buffs)
   for k,v in pairs(buffs) do
      self:addBuff(unit,v);
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
--====================================================================================================================
function class:receive1(args)
   self:addBuff(self.gameUnit);
   return 1;
end

function class:receive2(args)
   self:phoenixExcution(self.gameUnit);
   return 1;
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
