local class = summoner.Bootstrap.createUnitClass({label="システィーナ", version=1.3, id=102986312});

class.BUFF_BOX = {
   ID = 1029863121,
   BUFF_ID = 17,         --ダメージアップ
   VALUE = 100,        --効果量
   DURATION = 15,
   ICON = 26,
   SCRIPT = {
      SCRIPT_ID = 58
   }
}

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   if event.unit:getParameter("used") ~= "false" and event.unit:getParameter("used") ~= "true" then
      event.unit:setParameter("used","false")
   end
   self.gameUnit = event.unit
   return 1
end

function class:startWave(event)
   if self:findWeapon(event.unit,50234500) then
      self.BUFF_BOX.DURATION = 15
      self.BUFF_BOX.VALUE = 150
   end
   return 1
end

function class:findWeapon(unit,weaponId)
  local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
  return buff
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if event.unit:getParameter("used") == "false" then
      self:checkHp(event.unit)
   end
   return 1
end

function class:checkHp(unit)
   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   if hpRate <= 40 and unit:getLevel() >= 90 then
      unit:addSPWithPvpCorrection(200);
      unit:setParameter("used","true")
      self:execAddBuff(unit,self.BUFF_BOX)
   end
end

function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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

-- function class:takeSkill(event)--応急処置　ホストから呼ばれた時に危険なので必ず０
--   if event.index == 3 then
--     event.unit:setBurstPoint(0);
--   end
--   return 1;
-- end

-- function class:run(event)
--    if event.spineEvent == "paySP" then
--       event.unit:setBurstPoint(0);
--    end
--    return 1;
-- end

class:publish();

return class;