local class = summoner.Bootstrap.createUnitClass({label="ストラフ", version=1.3, id=102436511});

class.ICONS_LIST = {
	[1] = 44,
	[2] = 45,
	[3] = 43,
	[4] = 47,
	[5] = 46

}

function class:setBuffBox()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 1002,
         BUFF_ID = 21, --弱点属性ダメージUP
         VALUE = 20,
         TIME = 12,
         ICON_ID = 6,
         GROUP_ID = 10116,
         PRIORITY = 20,
         SCRIPT_ID = 28
      }
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
   if "addBuffStraf" == event.spineEvent then
      self:addBuffAll(event.unit)
   end
   return 1
end

function class:addBuffAll(unit)
   for i = 0,7 do
      local teamUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
      if teamUnit ~= nil then
         for k,buffBox in pairs(self.BUFF_BOX_LIST) do
            self:addBuff(teamUnit,buffBox);
         end
      end
   end
end

function class:addBuff(unit,buffBox)
	local iconID = self.ICONS_LIST[unit:getElementType()]

   if iconID == 0 then
      return;
   end

	if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
         local newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.TIME,iconID);
         newCond:setGroupID(buffBox.GROUP_ID);
         newCond:setPriority(buffBox.PRIORITY);
         if buffBox.SCRIPT_ID ~= nil then
           newCond:setScriptID(buffBox.SCRIPT_ID)
         end
      elseif cond == nil then
         local newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.TIME,iconID);
         newCond:setGroupID(buffBox.GROUP_ID);
         newCond:setPriority(buffBox.PRIORITY); 
         if buffBox.SCRIPT_ID ~= nil then
            newCond:setScriptID(buffBox.SCRIPT_ID)
         end
      end
	end

end

class:publish();

return class;