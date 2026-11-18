local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="回廊ヴァルザンデス", version=1.3, id=501251513});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 10,
    ATTACK2 = 5,
    ATTACK3 = 10,
    ATTACK4 = 0
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 0,
    SKILL2 = 100,
    SKILL3 = 0,
    SKILL4 = 0
}

class.ACTIVE_SKILLS = {
    SKILL1 = 1,
    ATTACK3 = 2,
    ATTACK1 = 3,
    ATTACK2 = 4,
    SKILL2 = 5,
    ATTACK4 = 6
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.DEAD_ATTACK_INDEX = 4;

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.deadCheckFlg = false;
    self.isRage = false;
    self.forceAttackIndex = 0;
    self.forceSkillIndex = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
    	{
            MESSAGE = self.TEXT.START_MESSAGE1 or "毒状態の相手に対してクリティカル率UP",
            COLOR = Color.magenta,
            DURATION = 5
    	},
    	    	{
            MESSAGE = self.TEXT.START_MESSAGE2 or "暗闇状態の相手に対してクリティカルダメージUP",
            COLOR = Color.magenta,
            DURATION = 5
    	},
    	    	{
            MESSAGE = self.TEXT.START_MESSAGE3 or "命中率UP",
            COLOR = Color.magenta,
            DURATION = 5
    	}
	}

    -- 怒り時のメッセージ
    self.RAGE_MESSAGES = {
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り状態：クリティカル率UP",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    -- HP0時メッセージ
    self.DEAD_MESSAGES = {
    	{
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ヴィラカーズからの誉れ",
            COLOR = Color.magenta,
            DURATION = 5
    	}
    }

	-- HP0時攻撃名
	self.ATTACK4_NAME = self.TEXT.ATTACK4 or "プライズミスト";

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    return 1;
end

function class:startWave(event)
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
	self:setReduceHitStop(event.unit);
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:setReduceHitStop(unit)
	if not self.isRage then
		unit:setReduceHitStop(2, 0.5);
	else
		unit:setReduceHitStop(2, 1.0);
	end
end

function class:run(event)
	if event.spineEvent == "forceDead" then return self:forceDead(event.unit) end
	if event.spineEvent == "addSP" then return self:addSP(event.unit) end
	return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.forceAttackIndex ~= nil and self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);

    if event.index == self.DEAD_ATTACK_INDEX then
        self:showMessages(event.unit,self.DEAD_MESSAGES);
        event.unit:showPopText(self.ATTACK4_NAME);
    end
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.forceSkillIndex ~= nil and self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:dead(event)
	if not self.deadCheckFlg then
		self.deadCheckFlg = true;
		return self:takeAttackDead(event.unit);
	end
	return 1;
end

function class:takeAttackDead(unit)
	unit:setHP(1);
	unit:setInvincibleTime(10);

    self.forceAttackIndex = self.DEAD_ATTACK_INDEX;

    unit:setAttackDelay(0);
    unit:setAttackTimer(0);
    return 0;
end

function class:forceDead(unit)
	unit:setHP(0);
	unit:setInvincibleTime(0);
	return 1;
end


function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            self:excuteTrigger(unit,self.HP_TRIGGERS[i]);
            self.HP_TRIGGERS[i] = nil;
            if self.hpMarkers[i] ~= nil then
                self.gameUnit:removeHpMarker(self.hpMarkers[i])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);

    self.forceSkillIndex = 1;
    unit:addSP(100);
    unit:setInvincibleTime(5);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
function class:showMessages(unit,messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
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


--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;