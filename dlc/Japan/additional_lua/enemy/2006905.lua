local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ゔぃしゃす", version=1.3, id=2006905});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

class.RAGE_ATTACKS = {
	[0] = 5,
	[1] = 4,
	[2] = 3
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
	ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    ATTACK3 = 5,
    ATTACK4 = 6,
    ATTACK5 = 7
}


class.BUFF_VALUE = 30;

--開始時メッセージ
class.START_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess1 or "神族キラー",
        COLOR = Color.yellow,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess2 or "物理ダメージ軽減",
        COLOR = Color.red,
        DURATION = 5
    }
};
--開始時メッセージ
class.RAGE_MESSAGE = {
    {
        MESSAGE = class.TEXT.mess3 or "兵器とは戦闘と共にあるもの",
        COLOR = Color.cyan,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess4 or "行動速度アップ",
        COLOR = Color.red,
        DURATION = 5
    }
};

--弱体時にかかるバフ内容
class.BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 28,         
        VALUE = 20,        
        DURATION = 9999999,
        ICON = 7
    },
    {
        ID = 40001172,
        EFID = 0,         
        VALUE = 20,        
        DURATION = 9999999,
        ICON = 182
    }
}

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.spValue = 20;
    event.unit:setNeedSP(100);--SPの必要量をデータで勝手に変えられないための自衛策
    event.unit:setSkillInvocationWeight(0);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.buddyCheckTimer = 0;
    self.buddyAliveFlag = true;
    self.attackCounter = 0;

	self.isOverHeat = false;
	self.aura = nil;

    self.HP_TRIGGERS = {
        [50] = "getRage"
    };
    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end

    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);

    if self.isRage then
	    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　50%軽減
	    event.unit:setBurstPoint(0);
	end

	if self.isOverHeat then
		self:auraControl(event.unit);
	end
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.isRage then
    	attackIndex = self.RAGE_ATTACKS[self.attackCounter%3];
    	self.attackCounter = self.attackCounter + 1;
    end

    if tonumber(attackIndex) == 2 then
    	self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    else
        unit:takeAttack(tonumber(attackIndex));
    end

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
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        skillIndex = 3;
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
    return 1
end

function class:run(event)
	if event.spineEvent == "takeOverHeat" and self:getIsHost() then
	end
	if event.spineEvent == "auraLoopStart" then
		self:auraLoopStart(event.unit);
	end
	return 1;
end


function class:addSP(unit)
  	if not self.isRage then
	    unit:addSP(self.spValue);
	end
    
    return 1;
end
--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
                if self.hpMarkers[i] ~= nil then
                    self.gameUnit:removeHpMarker(self.hpMarkers[i])
                end
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--=====================================================================================================================================

function class:overHeat(unit)
	if self.isOverHeat then
		self:finishOverHeat(unit);
	end
	self.isOverHeat = true;
	self.aura = unit:addOrbitSystem("auraIn");
	self.aura:takeAnimation(0,"auraIn",true);
	local vec = -1;
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
end


function class:finishOverHeat(unit)
	self.isOverHeat = false;
	self:auraEnd(unit);
end

function class:auraLoopStart(unit)
	self.aura:takeAnimation(0,"auraLoop",true);
end

function class:auraControl(unit)
	if self.aura == nil then
		return;
	end
	local vec = -1;
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
end

function class:auraEnd(unit)
	self.aura:takeAnimation(0,"auraEnd",false);
	self.aura = nil;
end


--=====================================================================================================================================

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

function class:getRage(unit)
    self.isRage = true;
    unit:setAttackDelay(0);
    self:showMessages(unit,self.RAGE_MESSAGE);
    self:addRageBuff(unit);
    self:overHeat(unit);
    if self:getIsHost() then
        unit:takeSkillWithCutin(3);
    end
end
--=====================================================================================================

function class:addRageBuff(unit)
    for i, v in ipairs(self.BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end


function class:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end
--=====================================================================================================
function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

--=====================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end


class:publish();

return class;