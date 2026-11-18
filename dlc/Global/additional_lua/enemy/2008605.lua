local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ゼルカラ", version=1.3, id=2008605});
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
        ID = 102381,
        EFID = 25,         --ブレイク耐性
        VALUE = -20,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

--怒り時にかかるバフ内容
class.ADVANCE_BUFF_ARGS = {
    {
        ID = 102382,
        EFID = 22,         --クリティカル率
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 11
    },
    {
        ID = 102383,
        EFID = 17,         --ダメージup
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 0,
        SCRIPT = 22 --クリティカルの時のみ発動
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
    self.isAdvanceRage = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
    }

    --開始時
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.mess1 or "八つ裂きにしてやるゥ！",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    --開始時魔族あり
    self.START_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.mess2 or "憎い…魔族は憎いィィィイイイイイ！",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.mess3 or "魔族キラー",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.mess4 or "闇属性耐性",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [3] = {
            MESSAGE = self.TEXT.mess5 or "クリティカル無効",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.mess6 or "もっと速く…強く…！",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }
    --ブレイク復帰時のメッセージ
    self.BREAK_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.mess8 or "消えろォオオオオ！",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.mess9 or "クリティカル率UP",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.DEAD_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.mess10 or "お嬢様…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    if self:checkRaceType(event.unit) then
    	self:showMessages(event.unit,self.START_MESSAGES2);
    else
    	self:showMessages(event.unit,self.START_MESSAGES);
    end
    return 1;
end

function class:update(event)
	if megast.Battle:getInstance():isHost() and self.hadBreak and event.unit.m_breaktime <= 0 and self.isRage and not self.isAdvanceRage then
        -- self.hadBreak = false;
        -- self:onBreakEnd(event.unit);
        -- megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
    end
    if self.isAdvanceRage then
        event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　100%軽減
    end
    self:HPTriggersCheck(event.unit);
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
        return 0;
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:takeBreake(event)
    self.hadBreak = true;
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


function class:checkRaceType(unit)
	local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
	for i = 0,7 do
	     local teamUnit = team:getTeamUnit(i);
	     if teamUnit ~= nil then  
	            if teamUnit:getRaceType() == 8 then
	                return true;
	            end
	     end
	end
	return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    -- self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    -- unit:addSP(unit:getNeedSP());
    self:showMessages(unit,self.RAGE_MESSAGES);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
--ブレイク復帰時関連

function class:onBreakEnd(unit)
	self:addBuffs(unit,self.ADVANCE_BUFF_ARGS);
	self:showMessages(unit,self.BREAK_MESSAGES);
	unit:addSP(unit:getNeedSP());
	self.isAdvanceRage = true;
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

function class:receive4(args)
    self:onBreakEnd(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;