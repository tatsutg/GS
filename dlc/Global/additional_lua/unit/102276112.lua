local class = summoner.Bootstrap.createUnitClass({label="タリス", version=1.3, id=102276112});

--不死鳥効果発動後のリキャスト
class.RECAST = 60;

function class:start(event)
	self.gameUnit = event.unit;--Receveからの呼び出し時に使う
	if event.unit:getLevel() < 90 then
        return 1;
    end
	self.phoenixTimer = 0;
	self.phoenixFlag = false;
	self:initPhoenixTimer(event);
	return 1;
end

function class:startWave(event)
	megast.Battle:getInstance():updateConditionView();
	return 1;
end

function class:update(event)
	if event.unit:getLevel() < 90 then
        return 1;
    end
	self:phoenixGaser(event);
	return 1;
end

function class:dead(event)
	if event.unit:getLevel() < 90 then
        return 1;
    end
	if self.phoenixFlag and self:isControllTarget(event.unit) then
		self.phoenixFlag = false;
		self.phoenixTimer = 0;
		self:phoenixExcution(event.unit);
    	if not megast.Battle:getInstance():isPvp() then
			megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
		end
		return 0;
	end
	self:setPhoenixTimer(event.unit);
	return 1;
end


--====================================================================================================================
--

function class:initPhoenixTimer(event)
	if self:getPhoenixTimer(event.unit) ~= 0 then
		self.phoenixTimer = self:getPhoenixTimer(event.unit);
	else
		self:addBuff(event.unit);
		self.phoenixTimer = 60;
		self.phoenixFlag = true;
	end
end

function class:phoenixGaser(event)
	if self.phoenixTimer < self.RECAST and self:isControllTarget(event.unit) then
		self.phoenixTimer = self.phoenixTimer + event.deltaTime;
		if self.phoenixTimer >= self.RECAST then
			self:addBuff(event.unit);
			megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
		end
	end
end

function class:addBuff(unit)
	unit:getTeamUnitCondition():addCondition(102116112,0,0,10000,37);
	self.phoenixFlag = true;
	megast.Battle:getInstance():updateConditionView();
end


function class:setPhoenixTimer(unit)
	local time = math.ceil(self.phoenixTimer);
	unit:setParameter("phoenixTimer",""..time); 
end

function class:getPhoenixTimer(unit)
	local tempTimer = unit:getParameter("phoenixTimer");
	if tempTimer ~= nil and tempTimer ~= "" and tempTimer ~= "false" then
		return tonumber(tempTimer);
	end
	return 0;
end

function class:phoenixExcution(unit)
	unit:setHP(unit:getCalcHPMAX()/2);
	unit:setInvincibleTime(5);
	self:removeAllBadstatus(unit);
	unit:takeSkillWithCutin(2);
	if unit:getisPlayer() then
		summoner.Utility.messageByPlayer(self.TEXT.mess1 or "煌華一刀流",5,summoner.Color.red);
	else
		summoner.Utility.messageByEnemy(self.TEXT.mess1 or "煌華一刀流",5,summoner.Color.red);
	end
	local buff =  unit:getTeamUnitCondition():findConditionWithID(102116112);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

function class:removeAllBadstatus(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
        end
    end
end

--====================================================================================================================

function class:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if megast.Battle:getInstance():isPvp() then
        return true;
	end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end

end
--====================================================================================================================
function class:receive1(args)
    self:addBuff(self.gameUnit);
    return 1;
end

function class:receive2(args)
	self:phoenixExcution(self.gameUnit);
	return 1;
end

class:publish();

return class;
