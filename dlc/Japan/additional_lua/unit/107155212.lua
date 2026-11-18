local class = summoner.Bootstrap.createUnitClass({label="リムル", version=1.3, id=107155212});

class.BUFF_ARGS = {
    [0] = {
		 ID = 1071552121,
		 BUFF_ID = 10,
		 VALUE =4,
		 DURATION = 15,
		 ICON = 36,
         GROUP_ID  = 3550,
         PRIORITY = 60
	},
	[1] = {
		 ID = 1071552122,
		 BUFF_ID = 70,
		 VALUE =3,
		 DURATION = 15,
		 ICON = 18,
		 SCRIPT = 105,
		 SCRIPTVALUE1 = 7
	}
}

function class:run(event)
   if event.spineEvent == "skillReload" then
      for i = 0,7 do
         local teamUnit = event.unit:getTeam():getTeamUnit(i,true)
         if teamUnit ~= nil then
            teamUnit:setSkillCoolTime(0);
         end
      end
   end
   if event.spineEvent == "addBuff" then
   		for i=0,6 do
   			local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i);
   			if teamUnit ~= nil then
   				self:execAddBuff(teamUnit,self.BUFF_ARGS[0]);
   			end
   		end
   		self:execAddBuff(event.unit,self.BUFF_ARGS[1]);
   end
   return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
  if buffBox.GROUP_ID ~= nil then
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
    if cond ~= nil then
        if cond:getPriority() > buffBox.PRIORITY then
            return;
        end
        unit:getTeamUnitCondition():removeCondition(cond);
    end
    self:addConditionWithGroup(unit,buffBox);
    return;
  end

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

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       newCond:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        newCond:setValue1(buffBox.SCRIPTVALUE1);
    end
 
end

class:publish();

return class;
