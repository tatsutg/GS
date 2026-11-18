local class = summoner.Bootstrap.createUnitClass({label="ヒジカタ", version=1.3, id=107133512});

class.BUFFID = 10713501;
class.ICON_BUFFID = 107136012;

function class:start(event)
	self.timer = 0;

	return 1;
end

function class:update(event)

	self.timer = self.timer + event.deltaTime;
	if self.timer >= 0.3 then
		self.timer = self.timer - 0.3;
		local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
		local iconBuff =  event.unit:getTeamUnitCondition():findConditionWithID(self.ICON_BUFFID);
		if cond ~= nil then
			if iconBuff == nil then
				iconBuff = event.unit:getTeamUnitCondition():addCondition(self.ICON_BUFFID,0,0,10000,3);
			end
			local count = cond:getValue3();
			iconBuff:setNumber(count <= 0 and 1 or count);
			megast.Battle:getInstance():updateConditionView();
		else
		    if iconBuff ~= nil then
		        unit:getTeamUnitCondition():removeCondition(iconBuff);
		    end
		end
	end
	
 	return 1;
end 

class:publish();

return class;