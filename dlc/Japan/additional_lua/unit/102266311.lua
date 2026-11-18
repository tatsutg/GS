local class = summoner.Bootstrap.createUnitClass({label="ヴィシャス", version=1.3, id=102266312});

class.HEAT_TIME = 15;

class.ACTIONS = {
	[0] = {
		animation = 5,
		action = function (unit)
			unit:setSkillEffectEnabled(false);
			local buff = unit:getTeamUnitCondition():addCondition(102261,17,100,99,26);
			buff:setScriptID(105);
			buff:setValue1(1);
			buff:setValue2(1);
			buff:setValue3(1);
		end
	},
	[1] = {
		animation = 4,
		action = function (unit)
			unit:setSkillEffectEnabled(true);
			local buff = unit:getTeamUnitCondition():addCondition(102261,0,0,0,0);
		end
	},
	[2] = {
		animation = 3,
		action = function (unit)
			unit:setSkillEffectEnabled(false);
			local buff = unit:getTeamUnitCondition():addCondition(102261,25,100,99,9);
			buff:setScriptID(105);
			buff:setValue1(1);
			buff:setValue2(1);
			buff:setValue3(1);
		end
	},
}

function class:start(event)
	self.gameUnit = event.unit;
	self.isOverHeat = false;
	self.skillCounter = 0;
	self.aura = nil;
	self.heatTimer = 0;
	return 1;
end

function class:update(event)
	if self.isOverHeat then
		self:auraControl(event.unit);
		self:heatCountUp(event.unit,event.deltaTime);
		event.unit:setBurstPoint(0);
	end
	return 1;
end

function class:takeBreakeDamageValue(event)
	if self.isOverHeat then
		return 0;
	end
	return event.value;
end


function class:takeSkill(event)
	if event.index == 1 and self.isOverHeat then
		self.fromHost = false;
		local animationIndex = self.skillCounter%3;
		event.unit:setNextAnimationName("attack"..self.ACTIONS[animationIndex].animation);
		event.unit:setNextAnimationEffectName("2-attack"..self.ACTIONS[animationIndex].animation);
		self.ACTIONS[animationIndex].action(event.unit);
		if self:isControllTarget(event.unit) then
			megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.skillCounter);
		end
		self.skillCounter = self.skillCounter + 1;
	end
	return 1;
end

function class:run(event)
	if event.spineEvent == "takeOverHeat" and self:isControllTarget(event.unit) then
		self:overHeat(event.unit);
		megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
	end
	if event.spineEvent == "auraLoopStart" then
		self:auraLoopStart(event.unit);
	end
	return 1;
end

--====================================================================================================================
function class:overHeat(unit)
	if self.isOverHeat then
		self:finishOverHeat(unit);
	end
	self.isOverHeat = true;
	self.skillCounter = 0;
	self.aura = unit:addOrbitSystem("auraIn");
	self.aura:setOrbitType(4)
	self.aura:takeAnimation(0,"auraIn",true);
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
    local buff = unit:getTeamUnitCondition():addCondition(102263,0,1,self.HEAT_TIME,182);
end

function class:heatCountUp(unit,deltaTime)
	if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
		return;
	end
	self.heatTimer = self.heatTimer + deltaTime;
	if self.heatTimer >= self.HEAT_TIME then
		self:finishOverHeat(unit);
	end
end

function class:finishOverHeat(unit)
	self.isOverHeat = false;
	self.heatTimer = 0;
	self:auraEnd(unit);
end

--====================================================================================================================

function class:auraLoopStart(unit)
	self.aura:takeAnimation(0,"auraLoop",true);
end

function class:auraControl(unit)
	if self.aura == nil then
		return;
	end
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
end

function class:auraEnd(unit)
	self.aura:takeAnimation(0,"auraEnd",false);
	self.aura = nil;
end

--====================================================================================================================
function class:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end
    return false;
end

--====================================================================================================================
function class:receive1(args)
    self:overHeat(self.gameUnit);
    return 1;
end

function class:receive2(args)
    self.skillCounter = args.arg;
    return 1;
end

class:publish();

return class;