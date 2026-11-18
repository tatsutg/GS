local class = summoner.Bootstrap.createUnitClass({label="スギモト", version=1.3, id=107116112});

--不死身効果発動後のリキャスト
class.RECAST = 60;

--不死身発動時にかかるバフ内容
class.BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 30,
        ICON = 26,
        SCRIPT = 58
    },
    {
        ID = 40076,
        EFID = 22,         --クリティカル
        VALUE = 100,        --効果量
        DURATION = 30,
        ICON = 11
    }
}

function class:start(event)
	self.gameUnit = event.unit;--Receveからの呼び出し時に使う
    self.phoenixCount = 0;
	if event.unit:getLevel() < 90 then
        return 1;
    end
	self.phoenixFlag = false;
	return 1;
end

function class:startWave(event)
    self:addStartBuff(event.unit);
	megast.Battle:getInstance():updateConditionView();
	return 1;
end

function class:update(event)
	return 1;
end

function class:dead(event)
	if event.unit:getLevel() < 90 then
        return 1;
    end
    if self:getPhoenixFlag(event.unit) then
        return 1;
    end
	if self.phoenixCount < 2 and self:isControllTarget(event.unit) then
		self.phoenixFlag = false;
		self.phoenixTimer = 0;
		self:phoenixExcution(event.unit);
    	if not megast.Battle:getInstance():isPvp() then
			megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
		end
		return 0;
	end
	return 1;
end


--====================================================================================================================
--



function class:addStartBuff(unit)
    if self:getPhoenixFlag(unit) then
        return;
    end
    if unit:getLevel() < 90 then
        return 1;
    end
	local buff = unit:getTeamUnitCondition():addCondition(107116112,0,0,10000,37);
    buff:setNumber(2 - self.phoenixCount);
	megast.Battle:getInstance():updateConditionView();
end


function class:setPhoenixFlag(unit)
	unit:setParameter("phoenixCntSugimoto",""..self.phoenixCount); 
end

function class:getPhoenixFlag(unit)
	local str = unit:getParameter("phoenixCntSugimoto");
    local cnt = tonumber(str);
	if str ~= nil and str ~= "" then
        self.phoenixCount = cnt;
        if cnt > 1 then
            return true;
        end
	end
	return false;
end

function class:phoenixExcution(unit)
	unit:setHP(unit:getCalcHPMAX());
	self:removeAllBadstatus(unit);
	self:addBuffs(unit,self.BUFF_ARGS);
	unit:addSPWithPvpCorrection(200);
    unit:playVoice("VOICE_FULLARTS_RANK6");
	if unit:getisPlayer() then
		summoner.Utility.messageByPlayer(self.TEXT.mess1,5,summoner.Color.red);
	else
		summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
	end
	local buff =  unit:getTeamUnitCondition():findConditionWithID(107116112);
    if buff ~= nil then
        if self.phoenixCount >= 1 then
            unit:getTeamUnitCondition():removeCondition(buff);
        else
            buff:setNumber(2 - (self.phoenixCount + 1));
            megast.Battle:getInstance():updateConditionView();
        end
    end
    self.phoenixCount = self.phoenixCount + 1;
    self:setPhoenixFlag(unit);
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


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end


function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
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
