local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2009043});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 23,         --クリティカル耐性アップ
        VALUE = -100,        --効果量
        DURATION = 9999999,
        ICON = 188
    },
    {
        ID = 40076,
        EFID = 28,         --行動速度
        VALUE = 35,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isOverHeat = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
    }

    --開始時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "訓練にはちょうどいい",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "覚悟しろ…貴様にあとはない",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "行動速度・クリティカル率耐性UP",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setEvolutionStage(2);
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end

function class:takeIdle(event)
	if self.isRage then
		self:animationSwitcher(event.unit,"idle");
	end
	return 1;
end

function class:takeDamage(event)
	if self.isRage then
		self:animationSwitcher(event.unit,"damage");
	end
	return 1;
end

function class:takeBack(event)
	if self.isRage then
		self:animationSwitcher(event.unit,"back");
	end
	return 1;
end

function class:takeFront(event)
	if self.isRage then
		self:animationSwitcher(event.unit,"front");
	end
	return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    event.unit:addSP(event.unit:getNeedSP());
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    if self.isOverHeat then
		self:auraControl(event.unit);
	end
    event.unit:setReduceHitStop(2,1);
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
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
    if self.isRage then
		self:animationSwitcher(event.unit,"attack"..event.index);
	end
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
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        if not self.isOverHeat then
        	self:overHeat(event.unit);
        end
        return 0;
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if self.isRage and event.index ~= 3 then
		self:animationSwitcher(event.unit,"skill"..event.index);
	end
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:animationSwitcher(unit,animName)
	unit:setNextAnimationName(animName.."-over");
end

--====================================================================================================================
function class:overHeat(unit)
	self.isOverHeat = true;
	self.skillCounter = 0;
	self.aura = unit:addOrbitSystem("aura_PTE");
	self.aura:takeAnimation(0,"aura_PTE",true);
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN") - 65;
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
end

--====================================================================================================================

--====================================================================================================================

function class:auraControl(unit)
	if self.aura == nil then
		return;
	end
	local vec = unit:getisPlayer() and 1 or -1;
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN") - 65;
    self.aura:setPosition(targetx,targety);
    self.aura:setZOrder(unit:getZOrder()+1);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
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
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
    unit:addSP(unit:getNeedSP());
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