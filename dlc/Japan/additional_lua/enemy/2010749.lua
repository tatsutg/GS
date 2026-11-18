local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="リヴィエラ", version=1.3, id=2010749});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 100
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 0,
    SKILL3 = 0
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

-- マギアドライブ時にかかるバフ
class.AURA_BUFF_ARGS = {
    -- クリティカル率アップ
    {
        ID = 20107491,
        EFID = 22,
        VALUE = 25,
        DURATION = 9999999,
        ICON = 11
    },
    -- 行動速度アップ
    {
        ID = 20107492,
        EFID = 28,
        VALUE = 20,
        DURATION = 9999999,
        ICON = 0
    }
}

class.START_WAVE_SKILL_INDEX = 2;
class.HP_TRIGGER_SKILL_INDEX = 3;
class.ORBIT_FILENAME_MD = "MD_3";
class.ORBIT_ANIMATION_NAME_MD_IN = "MD_in";
class.ORBIT_ANIMATION_NAME_MD_LOOP = "MD_loop";

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.forceSkillIndex = 0;
    self.isAura = false;
    self.orbitAura = nil;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [70] = "takeSkill3_1",
        [30] = "takeSkill3_2"
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "特大！ぶちこむ！",
            COLOR = Color.green,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "水属性へのダメージアップ",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    -- マギアドライブ時のメッセージ
    self.SKILL3_1_MESSAGES = {
        {
            MESSAGE = self.TEXT.SKILL3_1_MESSAGE1 or "滾ってきたぁ！",
            COLOR = Color.green,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.SKILL3_1_MESSAGE2 or "マギアドライブ：",
            COLOR = Color.green,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.SKILL3_1_MESSAGE3 or "行動速度・クリティカル率アップ",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    -- 真奥義時のメッセージ
    self.SKILL3_2_MESSAGES = {
        {
            MESSAGE = self.TEXT.SKILL3_2_MESSAGE1 or "あたしの本気、みせてあげる！",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [70] = self.gameUnit:addNumHpMarker(0.7),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }
    return 1;
end

function class:startWave(event)
    self:forceTakeSkill(event.unit,self.START_WAVE_SKILL_INDEX);
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:updateAura(event.unit);
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:run(event)
    if event.spineEvent == "addSP" then self:addSP(event.unit); end
    if event.spineEvent == "md3Start" then self:createAura(event.unit); end
    if event.spineEvent == "loopStart" then self.orbitAura:takeAnimation(0,"MD_loop",true); end
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

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
    self:addSP(event.unit);
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
    if event.index == self.HP_TRIGGER_SKILL_INDEX and self.isAura and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(self.HP_TRIGGER_SKILL_INDEX,1);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 真奥義(マギアドライブ)処理
    if event.index == self.HP_TRIGGER_SKILL_INDEX then 
        self:setupSkill3(event.unit);
    end
    return 1;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
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

function class:showMessages(unit,messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:executeTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
                if self.hpMarkers[i] ~= nil then self.gameUnit:removeHpMarker(self.hpMarkers[i]) end
            end
        end
    end
end

function class:executeTrigger(unit,trigger)
    if trigger == "takeSkill3_1" then
        self:forceTakeSkill(unit,self.HP_TRIGGER_SKILL_INDEX);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "takeSkill3_2" then
        if not self.isAura then
            return false;
        end

        self:forceTakeSkill(unit,self.HP_TRIGGER_SKILL_INDEX);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    return true;
end

function class:createAura(unit)
    if self.orbitAura ~= nil then
        return;
    end

    self.orbitAura = unit:addOrbitSystemWithFile(self.ORBIT_FILENAME_MD,self.ORBIT_ANIMATION_NAME_MD_IN);
    self:setAuraPosition(unit);
end

function class:updateAura(unit)
    if self.orbitAura == nil then
        return;
    end

    self:setAuraPosition(unit);
end

function class:setAuraPosition(unit)
    -- ユニットに座標を追従させる
    local unitX = unit:getPositionX() - unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local unitY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.orbitAura:setPosition(unitX,unitY);
    self.orbitAura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
    self.orbitAura:setZOrder(unit:getZOrder() + 1);
end

function class:forceTakeSkill(unit,index)
    self.forceSkillIndex = index;
    unit:addSP(100);
end

function class:setupSkill3(unit)
    -- 通常時
    if not self.isAura then
        self.isAura = true;
        self:addBuffs(unit,self.AURA_BUFF_ARGS);
        self:showMessages(unit,self.SKILL3_1_MESSAGES);
    -- マギアドライブ時
    else
         unit:setNextAnimationName("skill3_2");
         unit:setNextAnimationEffectName("2skill3_2");
         self:showMessages(unit,self.SKILL3_2_MESSAGES);
    end
end

function class:receive3(args)
    self:forceTakeSkill(self.gameUnit,self.HP_TRIGGER_SKILL_INDEX);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

class:publish();

return class;