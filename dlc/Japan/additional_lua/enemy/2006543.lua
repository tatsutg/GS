local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ボーゲン", version=1.3, id=2006543});
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
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--開始時メッセージ
class.START_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess1 or "no text",
        COLOR = Color.red,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess2 or "no text",
        COLOR = Color.cyan,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess3 or "no text",
        COLOR = Color.red,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess4 or "no text",
        COLOR = Color.red,
        DURATION = 5
    }
}


--ブレイク復帰メッセージ
class.BREAKED_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess5 or "no text",
        COLOR = Color.red,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess6 or "no text",
        COLOR = Color.red,
        DURATION = 5
    }
}



--怒り時にかかるバフ内容
class.BREAK_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --攻撃アップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 40;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.hadBreak = false;
    self.breakCount = 0;

    self.HP_TRIGGERS = {
        [50] = "getRage"
    };

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end

function class:startWave(event)
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    if megast.Battle:getInstance():isHost() and self.hadBreak and event.unit.m_breaktime <= 0 then
        self.hadBreak = false;
        self:addBreakedBuff(event.unit,self.breakCount);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.breakCount);
    end
    if self.isRage then
        event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　100%軽減
    end
    self:HPTriggersCheck(event.unit);
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
    -- self:attackActiveSkillSetter(event.unit,event.index);
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

--=====================================================================================================================================
function class:addBreakedBuff(unit,rate)
    for i, v in ipairs(self.BREAK_BUFF_ARGS) do
        self:addBuff(unit, v,rate);
    end
    self:showMessages(unit,self.BREAKED_MESSAGES);
end

function class:addBuff(unit,args,rate)
    if rate == nil then
        rate = 1;
    end
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE * rate,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
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
function class:getRage(unit)
    self.isRage = true;
end


function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end


function class:receive4(args)
    self:addBreakedBuff(self.gameUnit);
    return 1;
end


class:publish();

return class;