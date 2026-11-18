local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="召喚用雑魚植物", version=1.3, id=600000043});

class.DAMAGERATE = 0.01;

function class:start(event)
   event.unit:getSkeleton():setScaleX(-1);
   return 1;
end

--燃焼でもダメージでも殺せるようにしときたいので、luaからダメージをカットする（被ダメアップ対策）
function class:takeDamageValue(event)
	local result = math.floor(event.value*self.DAMAGERATE);
	result = result < 1 and 1 or result;--１未満は１に
	return result;
end

--ボスがいなければ自害するようにしておく
function class:update(event)
	if not self:findUnit(event.unit,40145) then
		event.unit:setHP(0);
	end
   return 1;
end

function class:findUnit(unit,unitID)
   for i = 0, 7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil and localUnit:getBaseID3() == unitID then
         return true
      end
   end
   return false
end

class:publish();

return class;