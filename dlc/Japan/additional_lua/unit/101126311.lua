local class = summoner.Bootstrap.createUnitClass({label="ギリアム", version=1.3, id=101126311});

class.BUFF_BOX = {
   ID = 1011263111,
   BUFF_ID = 17, -- 装備ダメージ
   VALUE = 20,
   DURATION = 999999,
   ICON = 114,
   SCRIPT = {
      SCRIPT_ID = 59
   }
}

function class:startWave(event)
   if self:findWeapon(event.unit,50261100) then
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
         if teamUnit ~= nil then
            self:execAddBuff(teamUnit,self.BUFF_BOX)
         end
      end
   end
   return 1
end

function class:findWeapon(unit,weaponId)
   local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
   return buff ~= nil
end



function class:execAddBuff(unit,buffBox)
   local buff;
   if buffBox.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
   else
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
   end

   if buffBox.SCRIPT ~= nil then
      buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
      if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
      if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
      if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
      if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
      if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
   end
end

class:publish();

return class;