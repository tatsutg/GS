local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="パルラミシア", version=1.3, id=2007937});
class:inheritFromUnit("unitBossBase");

class.INVINCIBLE_TIME = 2.5
class.SP_DAMAGE = 25;

class.COUNTER_NM = "skill2counter"
class.CANCEL_NM = "skill2Failed"

class.COUNTER_EF = "2skill2counter"
class.CANCEL_EF = "2skill2Failed"

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 80,
    ATTACK2 = 20
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
    -- {
    --     ID = 40075,
    --     EFID = 17,         --ダメージアップ
    --     VALUE = 100,        --効果量
    --     DURATION = 9999999,
    --     ICON = 26
    -- }
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
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
    }

    -- if table.maxn(self.TEXT) == 0 then
    --     self.TEXT = {
    --         START_MESSAGE1 = "いざ、尋常に…",
    --         START_MESSAGE2 = "光・闇ダメージ軽減",
    --         DEAD_MESSAGE1 = "なんという…腕前…",
    --         SUMMARY = "奥義ゲージ減少"
    --     }
    -- end

    --開始時時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1,
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    --死亡時のメッセージ
    self.DEAD_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.DEAD_MESSAGE1,
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [1] = {
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
    self.isCounterSuccess = false;
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
    self.isCounterSuccess = false;
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




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:dead(event)
    self:showMessages(event.unit,self.DEAD_MESSAGES);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    return 1;
end


function class:run(event)
  if "counter" == event.spineEvent and self:getIsHost() then
    self.isCounter = true
  end
  if "cancel" == event.spineEvent and self:getIsHost() then
    self.isCounter = false
    self:cancelImpl(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,5,1)
  end
  return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
     local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if self.isCounter and self:getIsHost() and (skillType == 1 or skillType == 2 or skillType ==3 or skillType == 6) then
        self.isCounter = false
        self.isCounterSuccess = true
        self:counterImpl(event.unit)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
        return 0
    end
  return event.value
end

function class:counterImpl(unit)
    unit:setInvincibleTime(self.INVINCIBLE_TIME)
    unit:setAnimation(0,self.COUNTER_NM,false)
    unit:takeAnimationEffect(0,self.COUNTER_EF,false)
end

function class:cancelImpl(unit)
    unit:setAnimation(0,self.CANCEL_NM,false)
    unit:takeAnimationEffect(0,self.CANCEL_EF,false)
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
  self.isCounter = false
  return 1 
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.isCounterSuccess then
        local point = event.enemy:getBurstPoint();
        event.enemy:setBurstPoint(point - self.SP_DAMAGE < 0 and 0 or point - self.SP_DAMAGE);
        event.enemy:playSummary(self.TEXT.SUMMARY,true);
    end

    return event.value
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
    unit:removeHpMarker(self.hpMarkers[1].MARKER)
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


function class:receive4(args)
    self.isCounter = false
    self.isCounterSuccess = true
    self:counterImpl(self.gameUnit)
    return 1;
end


function class:receive5(args)
    self:cancelImpl(self.gameUnit)
    return 1;
end

function class:receive6(args)
    self:showMessages(self.gameUnit,self.DEAD_MESSAGES);
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;