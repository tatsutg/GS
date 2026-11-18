local class = summoner.Bootstrap.createUnitClass({label="イオ", version=1.3, id=102716412});

function class:setBuffBox()
   self.BUFF_BOX =  {
      ID = -1,
      BUFF_ID = 98, -- 無効化
      VALUE = 0,
      DURATION = 20,
      ICON = 24,
      EFFECT = 1
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self:setBuffBox()
   return 1
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "barrier" then
      local pay = (event.unit:getCalcHPMAX()/100) * 30;
      if event.unit:getHP() < pay then
         pay = event.unit:getHP() -1;
         event.unit:setHP(1);
      else
         event.unit:setHP(event.unit:getHP() - pay);
      end
      self.BUFF_BOX.VALUE = pay > 0 and pay or 1
      self:execAddBuff(event.unit,self.BUFF_BOX)
   end

   if event.spineEvent == "weapon" then
      local orbit = event.unit:addOrbitSystemWithFile("10271ef","weapon")
      orbit:setDamageRateOffset(0.5)
      orbit:setBreakRate(0.5)
      event.unit:setDamageRateOffset(0.5)
      event.unit:setBreakRate(0.5)
   end
   return 1
end



-- バフ処理実行
function class:execAddBuff(unit,buffBox)
  local buff  = nil;
  if buffBox.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
  else
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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