local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=0});

function class:start(event)
	self.gameUnit = event.unit;
	return 1;
end

function class:run(event)
  if "takeHeal" == event.spineEvent then
  	self:takeHeal(event.unit,self.gameUnit);
  end

  return 1
end

function class:takeHeal(unit)
	if not self:getIsControll(unit) then
		return;
	end
	local fiewHP = 100;
	local targetIndex = unit:getIndex();
	for i = 0,7 do
		local teamUnit = unit:getTeam():getTeamUnit(i);
		if teamUnit ~= nil and 100 * teamUnit:getHP()/teamUnit:getCalcHPMAX() <  fiewHP then
		fiewHP = 100 * teamUnit:getHP()/teamUnit:getCalcHPMAX();
		targetIndex = i;
		end
 	end
 	self:excuteHeal(unit,targetIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,targetIndex);
end

function class:excuteHeal(unit,index)
	local teamUnit = unit:getTeam():getTeamUnit(index);
	local rate = 1;
	if teamUnit ~= nil then
		rate = (100 + teamUnit:getTeamUnitCondition():findConditionValue(115) + teamUnit:getTeamUnitCondition():findConditionValue(110))/100;
		teamUnit:takeHeal(teamUnit:getCalcHPMAX() * rate,self.gameUnit);
	end
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive2(args)
    self:excuteHeal(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;