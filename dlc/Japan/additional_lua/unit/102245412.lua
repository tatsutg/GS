local class = summoner.Bootstrap.createUnitClass({label="ミクス", version=1.3, id=102245412});

class.SKILL_1 = 1
class.SKILL_2 = 2

class.INVINCIBLE_TIME_1 = 3
class.INVINCIBLE_TIME_2 = 5

class.CANCEL_WAIT = "cancel"
class.IS_SKILL_3 = "skill3"

class.SUCCESS_COUNTER_1 = 1
class.SUCCESS_COUNTER_2 = 2
class.RECEIVE_NO_CHANGE_WAIT = 1

function class:start(event)
	self.myUnit = event.unit
	self.isWaitCounter = false
	self.counter_no = 0
	return 1
end

function class:run(event)
	if (self.IS_SKILL_3 or self.CANCEL_WAIT == event.spineEvent) and self:isControll(event.unit) then
		self.isWaitCounter = false
	end
	return 1
end

function class:receive1(arg)
	self.counter_no = arg.arg
	self:counterImpl(self.myUnit)
	return 1
end

function class:takeSkill(event)
	if (self.SKILL_1 == event.index or self.SKILL_2 == event.index) and self:isControll(event.unit) then
		self.isWaitCounter = true
		self.counter_no = event.index
	end
	return 1
end

function class:isControll(unit)
	return unit:isMyunit() or self:isMine(unit)
end

function class:isMine(unit)
	return not unit:getisPlayer() and megast.Battle:getInstance():isHost()
end

function class:takeDamage(event)
	if self:isControll(event.unit) then
		self.isWaitCounter = false
	end
	return 1
end

function class:takeDamageValue(event)
	if self.isWaitCounter and self:isControll(event.unit) then
		self.isWaitCounter = false
		self:counterImpl(event.unit)
		megast.Battle:getInstance():sendEventToLua(self.scriptID,self.RECEIVE_NO_CHANGE_WAIT,self.counter_no)
		return 0
	end
	return event.value
end

function class:counterImpl(unit)
	if self.SKILL_1 == self.counter_no then
		unit:setInvincibleTime(self.INVINCIBLE_TIME_1)
	else
		unit:setInvincibleTime(self.INVINCIBLE_TIME_2)
	end

	unit:setAnimation(0,"skill" .. self.counter_no .. "_counter",false)
	unit:takeAnimationEffect(0,"2skill" .. self.counter_no .. "_counter",false)
end

class:publish();

return class;
