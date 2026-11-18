local class = summoner.Bootstrap.createUnitClass({label="サイ", version=1.6, id=102786212});

function class:start(event)
	self.skill3FLG = false;
	return 1
end

function class:update(event)
	if self.skill3FLG then
		self.skill3FLG = false;
		event.unit:getBurstSkill2():runSkillEffectWithID(20278701,false);
	end
	return 1
end

function class:run(event)
	if event.spineEvent == "execItemCool" then
		event.unit:getBurstSkill2():runSkillEffectWithID(20278702,false);
	end
	return 1;
end

function class:takeSkill(event)
	if event.index == 3 then
		event.unit:setIsDisableSkillEffect(true)
		self.skill3FLG = true;
	end
	return 1
end

class:publish();

return class;
