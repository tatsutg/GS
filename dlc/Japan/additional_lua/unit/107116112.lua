local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒杉本", version=2.6, id=107116112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 107116112,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 10000,
            ICON = 37,
            COUNT = 2
        }
    }
end

function class:start(event)
	self.gameUnit = event.unit;
    self:setBuffBoxList()
    self.phoenixCount = 0;
	if event.unit:getLevel() < 90 then
        return 1;
    end
	return 1;
end

function class:startWave(event)
    if event.waves == 1 then
        self:addStartBuff(event.unit);
    end
	return 1;
end

function class:addStartBuff(unit)
    if unit:getLevel() < 90 then
        return 1;
    end
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    megast.Battle:getInstance():updateConditionView();
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    self:addStartBuff(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    self:phoenixExecution(event.unit);
    return 1
end

function class:phoenixExecution(unit)
    self:removeAllBadStatus(unit);
    unit:playVoice("VOICE_FULLARTS_RANK6");
	if unit:getisPlayer() then
		summoner.Utility.messageByPlayer(self.TEXT.mess1,5,summoner.Color.red);
	else
		summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
	end
    self.phoenixCount = self.phoenixCount + 1;
	local buff =  unit:getTeamUnitCondition():findConditionWithID(107116112);
    if buff ~= nil then
        if self.phoenixCount >= 2 then
            unit:getTeamUnitCondition():removeCondition(buff);
        else
            buff:setNumber(2 - self.phoenixCount);
            megast.Battle:getInstance():updateConditionView();
        end
    end
end

function class:removeAllBadStatus(unit)
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

function class:execAddBuff(unit,buffBox)
    local buff;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
    buff:setNumber(buffBox.COUNT);
end

class:publish();

return class;
