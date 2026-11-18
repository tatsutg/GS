local class = summoner.Bootstrap.createUnitClass({label="サイ", version=1.6, id=102786212});

class.HPBorder = 0.6;


function class:start(event)
	self.gameUnit = event.unit;
	self.item = nil;
	return 1;
end




function class:run(event)
	if event.spineEvent == "execItemCool" then
		if self:getIsControll(event.unit) then
			self.item = self:sharchHealItems(event.unit);
			if self.item ~= nil and self.item:getCoolTimer() > 0.1 and event.unit:getHP()/event.unit:getCalcHPMAX() <= self.HPBorder then
				self.item:setCoolTimer(0.1);
				megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
			end
		else
			return 1;
		end
	end
	return 1;
end

function class:sharchHealItems(unit)
	-- 上位状態異常、呪い
    local curse = unit:getTeamUnitCondition():findConditionValue(206)
	if curse > 0 then
		return nil;
	end
	for i=0,3 do
		
		local battleSkill = unit:getItemSkill(i);
		local slot = self:askSlot(battleSkill);
		if slot == 3 then
			return battleSkill;
		end
	end
	return nil;
end

function class:askSlot(battleSkill)
	if battleSkill == nil then
		return 0;
	end
	local battleItem = battleSkill:getBattleItem();
	if battleItem == nil then
		return 0;
	end
	return battleItem:getSlotIndex();
end

function class:receive1(args)
	self.item = self:sharchHealItems(self.gameUnit);
	if self.item ~= nil then
		self.item:setCoolTimer(0.1);
	end
	return 1;
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end


class:publish();

return class;
