local class = summoner.Bootstrap.createUnitClass({label="サイタマ", version=1.3, id=107076412});

class.ATTACK_TBL = {
	attack1 = 1,
	attack2 = 1
}

class.BUFF_ID = 10707;

function class:start(event)
	self.attackFlg = false
	self.recastTimer = 0;
    self.gameUnit = event.unit;
    self.isContinue = event.unit:getParameter("isStart707") == "true";

    event.unit:setParameter("isStart707","true"); 
	return 1
end

function class:takeAttack(event)
	if self.attackFlg == false then
		self.attackFlg = true
		self:implAttack(event.unit)
		return 0
	end
	self.attackFlg = false
	return 1
end

function class:implAttack(unit)
	local attackKeyName = summoner.Random.sampleWeighted(self.ATTACK_TBL)
	local attackStr = string.gsub(attackKeyName,"attack","")
	local attackNo = tonumber(attackStr)
	unit:takeAttack(attackNo)
end


function class:update(event)
    if self.isContinue then
        event.unit:takeAnimation(0,"in2",false);
        self.isContinue = false;
    end
    self.recastTimer = self.recastTimer - event.deltaTime;
    if self.recastTimer <= 0 and self:getIsControll(event.unit) then
        local hpRate = summoner.Utility.getUnitHealthRate(event.unit) * 100;
        if hpRate <= 40 then
            self:addBuff(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
    end
    return 1;
end


function class:addBuff(unit)
    local level = unit:getLevel();
    if level >= 90 then
        unit:getTeamUnitCondition():addCondition(self.BUFF_ID,98,2800,20,24,1);
    end
    self.recastTimer = 60;
end


function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end

class:publish();

return class;