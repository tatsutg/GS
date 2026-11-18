local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="カボチャ闇", version=1.3, id=501471513});


class.UNIT_ID = 501471513;
class.HP_RATE = 0.002;
class.POINT = 200000;
class.RAID_RATE = 1.75;

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [1] = {
         ID = 514000 + self.index,
         BUFF_ID = 22, -- クリティカル
         VALUE = 25,
         DURATION = 999999,
         ICON = 11
      }
   }

   self.FORPLAYER = false;
end


function class:start(event)
	self.animNum = Random.range(1,4);
	self.index = 0;
	self.conditionCheckTimer = 0;
	self.firstUpdate = false;
	
	event.unit:setRange_Max(10000);
	event.unit:setRange_Min(-10000);
	self.TEXT.DEAD_MESSAGE1 = self.TEXT.DEAD_MESSAGE1 or "パープルパンプキンを撃破して+%dpt";

	self.xpos = Random.range(1,600) - 300;
	self.ypos = Random.range(1,400) - 200;
	

	return 1;
end


function class:sarchKaboshelm(unit)
	local team = megast.Battle:getInstance():getTeam(false);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 40146 then
            return target;
        end
    end
    return nil;
end


--カボシェルムが持っているパラメーターから現在の撃破数をもらうよ
function class:getDefeatCount()
	if self.kaboshelm == nil then
		return 0;
	end

	local str = self.kaboshelm:getParameter(""..self.UNIT_ID);
	if str == nil or str == "" then
		return 0;
	end
	return tonumber(str);
end

--カボシェルムの持ってるパラメータに加算するよ
function class:setDefeatCount()
	if self.kaboshelm == nil then
		return;
	end

	local cnt = self:getDefeatCount();
	local newCnt = cnt + 1;
	self.kaboshelm:setParameter(""..self.UNIT_ID,""..newCnt);
end



function class:setHP(unit)
	if self.kaboshelm == nil then
		unit:setHP(0);
		return;
	end
	local defeatRate = 1 + self.defeatCount * 0.1;
	unit:setBaseHP(self.kaboshelm:getCalcHPMAX() * self.HP_RATE *  math.pow(defeatRate,2));
	unit:setHP(self.kaboshelm:getCalcHPMAX() * self.HP_RATE *  math.pow(defeatRate,2))
end

function class:getUniqueIndex(unit)
	--このパラメーターは生成時にカボシェルムによって付与されます
	local indexStr = unit:getParameter("kabocha_index");
	if indexStr == nil or indexStr == "" then
		self.index = 0;
	end
	self.index = tonumber(indexStr);
end

function class:getRaidRate(unit)
	--このパラメーターは生成時にカボシェルムによって付与されます
	local rateStr= unit:getParameter("raid_rate");
	if rateStr== nil or rateStr== "" then
		self.index = 0;
	end
	self.RAID_RATE = tonumber(rateStr);
end

function class:firstIn(event)
	if self.animNum == 2 then
		event.unit:setNextAnimationName("in2")
	elseif self.animNum == 3 then
		event.unit:setNextAnimationName("in3")
	end
	return 1;
end

function class:takeIdle(event)
	if self.animNum == 2 then
		event.unit:setNextAnimationName("idle2")
	elseif self.animNum == 3 then
		event.unit:setNextAnimationName("idle3")
	end
	return 1;
end

function class:update(event)
	if not self.firstUpdate then
		self.firstUpdate = true;
		self.kaboshelm = self:sarchKaboshelm(event.unit);
		self.defeatCount = self:getDefeatCount();
		self:setHP(event.unit);
		self:getUniqueIndex(event.unit);
		self:getRaidRate(event.unit);
		self:setBuffBoxList();

	
		event.unit:takeAnimation(0,"in",false);
		if not self.FORPLAYER and self.kaboshelm ~= nil then
			self:execAddBuff(self.kaboshelm,self.BUFF_LIST[1]);
		end
		
	end
	if self:sarchKaboshelm(event.unit) == nil then
		event.unit:setHP(0);
	end
	event.unit:setPosition(self.xpos,self.ypos);
	self:sarchConditionTartget(event.unit,event.deltaTime);
	return 1;
end


function class:takeFront(event)
	event.unit:takeIdle();
	return 0;
end

function class:takeBack(event)
	event.unit:takeIdle();
	return 0;
end

function class:takeSkill(event)
	event.unit:takeIdle();
	return 0;
end


function class:takeAttack(event)
	event.unit:takeIdle();
	return 0;
end

function class:takeDamage(event)

	if self.animNum == 2 then
		event.unit:setNextAnimationName("idle2")
	elseif self.animNum == 3 then
		event.unit:setNextAnimationName("idle3")
	else
		event.unit:setNextAnimationName("idle")
	end
	return 1;
end

function class:takeDamageValue(event)
	local damagePoint = math.floor(event.value);
	RaidControl:get():addBattlePoint(damagePoint,0);
	return event.value;
end

function class:dead(event)
	if self.animNum == 2 then
		event.unit:setNextAnimationName("out2")
	elseif self.animNum == 3 then
		event.unit:setNextAnimationName("out3")
	end
	if self:sarchKaboshelm(event.unit) == nil then
		return 1;
	end
	self:setDefeatCount();
	RaidControl:get():addBattlePoint(self.POINT/self.RAID_RATE,0);
	local message = string.format(self.TEXT.DEAD_MESSAGE1,self.POINT);
	summoner.Utility.messageByEnemy(message,5,Color.magenta);
	self:removeConditionTartget(event.unit);
	return 1;
end

function class:sarchConditionTartget(unit,deltaTime)
	if not self.FORPLAYER then
		return;
	end
	self.conditionCheckTimer = self.conditionCheckTimer + deltaTime;
	if self.conditionCheckTimer < 1 then
		return;
	end

	self.conditionCheckTimer = self.conditionCheckTimer - 1;

	local team = megast.Battle:getInstance():getTeam(not unit.getisPlayer);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID) == nil then
            self:execAddBuff(target,self.BUFF_LIST);
        end
    end

end

function class:removeConditionTartget(unit)

	if not self.FORPLAYER then
		local buff = self.kaboshelm:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
    	if buff ~= nil then
        	self.kaboshelm:getTeamUnitCondition():removeCondition(buff);
        end
		return;
	end

	local team = megast.Battle:getInstance():getTeam(not unit.getisPlayer);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil then
        	local buff = target:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
        	if buff ~= nil then
            	target:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end

end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
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

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end



class:publish();

return class;