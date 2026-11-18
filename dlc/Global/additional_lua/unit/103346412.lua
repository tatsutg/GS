local class = summoner.Bootstrap.createUnitClass({label="セラ", version=1.3, id=103346412});

function class:start(event)
   self.gameUnit = event.unit
   self.buffIndex = 1
   return 1
end

function class:takeSkill(event)
   if event.index == 1 then
      self:addBuff(event.unit,self.buffIndex)
      --megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.buffIndex);
      self.buffIndex = self.buffIndex == 2 and 1 or 2
   end
   return 1
end


-- バフ処理実行
function class:addBuff(unit,buffIndex)
   local myTeam = megast.Battle:getInstance():getTeam(unit:getisPlayer());
   for i = 0,6 do
      local myTeamUnit = myTeam:getTeamUnit(i)
      if myTeamUnit ~= nil then
         self:execAddBuff(myTeamUnit,buffIndex)
      end
   end
end

function class:execAddBuff(unit,i)
   if i == 1 then
      unit:addSPWithPvpCorrection(10)
   else
      unit:takeHeal(unit:getCalcHPMAX()*0.1,self.gameUnit)
   end
end

class:publish();

return class;