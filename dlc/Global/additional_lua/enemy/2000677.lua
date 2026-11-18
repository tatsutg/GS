local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="パルラミシア  ２７階", version=1.3, id=2000677});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50,
    ATTACK6 = 50,
    ATTACK7 = 50,
    ATTACK8 = 50,
    ATTACK9 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    ATTACK8 = 8,
    ATTACK9 = 9,
    SKILL1 = 10,
    SKILL2 = 11,
    SKILL4 = 13,
    SKILL5 = 14,
    SKILL6 = 19
}

class.COUNTER_ACTIVESKILLS = {
    [3] = 13,
    [4] = 14,
    [5] = 15,
    [6] = 16,
    [7] = 17,
    [8] = 18
}



--怒り時にかかるバフ内容
class.HP60_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 25,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.HP50_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 9,         --奥義ゲージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}

class.HP40_BUFF_ARGS = {
    {
        ID = 40077,
        EFID = 22,         --
        VALUE = 10,        --効果量
        DURATION = 9999999,
        ICON = 11
    },
    {
        ID = 40078,
        EFID = 17,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 22
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
    self.skillCheckFlg2 = false;
    
    self.counterAFlag = false;
    self.counterBFlag = false;
    self.beforeAttackNum = 0;
    self.forceSkillIndex = 0;
    self.hitStopValue = 0;


    event.unit:setSkillInvocationWeight(0);



    self.HP_TRIGGERS = {
        [80] = "hp80Trigger",
        [70] = "hp70Trigger",
        [60] = "hp60Trigger",
        [50] = "hp50Trigger",
        [40] = "hp40Trigger",
        [30] = "hp30Trigger",
        [20] = "hp20Trigger"
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "庇うキラー",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "被ダメージ回復",
            COLOR = Color.green,
            DURATION = 5
        }
    }



    --怒り時のメッセージ
    self.HP80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "常に奥義ゲージ減少",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP70_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "被ダメージ回復量上昇",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    self.HP60_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP40_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "クリティカル率アップ",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "クリティカルダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.HP30_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }



    self.COUNTER_MESSAGES_A = {
        [0] = {
            MESSAGE = self.TEXT.COUNTER_MESSAGE_A or "水陣の構え",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.COUNTER_MESSAGES_B = {
        [0] = {
            MESSAGE = self.TEXT.COUNTER_MESSAGE_B or "水天の構え",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2, self.hitStopValue);
    return 1;
end

function class:run(event)
    if event.spineEvent == "addSP" then  self:addSP(event.unit) end
    if event.spineEvent == "startCounterA" then  self:startCounterA(event.unit) end
    if event.spineEvent == "startCounterB" then  self:startCounterB(event.unit) end
    if event.spineEvent == "endCounterA" then  self:endCounterA(event.unit) end
    if event.spineEvent == "endCounterB" then  self:endCounterB(event.unit) end
    if event.spineEvent == "setupAnimation" then  self:setupAnimation(event.unit) end
    if event.spineEvent == "showCounterInfoA" then  self:showCounterInfoA(event.unit) end
    if event.spineEvent == "showCounterInfoB" then  self:showCounterInfoB(event.unit) end
    if event.spineEvent == "specialEF" then  self:takeSpecialEffect(event.unit) end
    return 1;
end

function class:takeDamage(event)
    event.unit:setSetupAnimationNameEffect("");
    event.unit:setSetupAnimationName("");
    self.counterAFlag = false;
    self.counterBFlag = false;
    return 1;
end

function class:takeDamageValue(event)
    if self.counterAFlag then
        local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType == 1 or skillType ==3 or skillType == 6 then
            self.skillCheckFlg = true;
            event.unit:setSetupAnimationNameEffect("setupA");
            event.unit:setSetupAnimationName("setupA");
            event.unit:setHitStopTimeSelf(0);
            event.unit:setInvincibleTime(2);
            event.unit:takeSkill(5);
            self.counterAFlag = false;
        elseif skillType == 2 then
            event.unit:takeDamage();
        end
    end
    if self.counterBFlag then
        local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType == 1 or skillType ==3 or skillType == 6 then
            self.skillCheckFlg = true;
            event.unit:setSetupAnimationNameEffect("setupB");
            event.unit:setSetupAnimationName("setupB");
            event.unit:setHitStopTimeSelf(0);
            event.unit:setInvincibleTime(2);
            event.unit:takeSkill(4);
            self.counterBFlag = false;
        elseif skillType == 2 then
            event.unit:takeDamage();
        end

    end
    return event.value;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    unit:takeAttack(tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self.beforeAttackNum = event.index;
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end
    unit:takeSkill(tonumber(skillIndex));
    return 0;
end

function class:takeSkill(event)
    self.counterAFlag = false;
    self.counterBFlag = false;

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if (event.index == 6 or event.index == 1) and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if self.isRage and event.index ~= 3 then
        self:animationSwitcher(event.unit,"skill"..event.index);
    end

    if event.index == 4 or event.index == 5 then
        event.unit:setActiveSkill(self.COUNTER_ACTIVESKILLS[self.beforeAttackNum]);
    end

    return 1
end


function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end
--===================================================================================================================




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
    if trigger == "hp80Trigger" then
        self:HP80Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp70Trigger" then
        self:HP70Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp60Trigger" then
        self:HP60Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp50Trigger" then
        self:HP50Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp40Trigger" then
        self:HP40Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp30Trigger" then
        self:HP30Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end

    if trigger == "hp20Trigger" then
        self:HP20Trigger(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
end

--===================================================================================================================
--怒り関係

function class:HP80Trigger(unit)
    self.forceSkillIndex = 6;
    unit:addSP(unit:getNeedSP());
    self:showMessages(unit,self.HP80_MESSAGES);
end

function class:HP70Trigger(unit)
   
    self:showMessages(unit,self.HP70_MESSAGES);
end

function class:HP60Trigger(unit)
    self:addBuffs(unit,self.HP60_BUFF_ARGS);
    self:showMessages(unit,self.HP60_MESSAGES);
end

function class:HP50Trigger(unit)
    self:addBuffs(unit,self.HP50_BUFF_ARGS);
    self:showMessages(unit,self.HP50_MESSAGES);
end

function class:HP40Trigger(unit)
    self:addBuffs(unit,self.HP40_BUFF_ARGS);
    self:showMessages(unit,self.HP40_MESSAGES);
end

function class:HP30Trigger(unit)
    self.hitStopValue = 0.5;
    self:showMessages(unit,self.HP30_MESSAGES);
end

function class:HP20Trigger(unit)
    self.forceSkillIndex = 1;
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

function class:showCounterInfoA(unit)
    self:showMessages(unit,self.COUNTER_MESSAGES_A);
    self.counterAFlag = true;
end

function class:showCounterInfoB(unit)
    self:showMessages(unit,self.COUNTER_MESSAGES_B);
    self.counterBFlag = true;
end

function class:setupAnimation(unit)
    self.gameUnit:setSetupAnimationNameEffect("");
    self.gameUnit:setSetupAnimationName("");
    return 1;
end

function class:startCounterB(unit)
    unit:takeAnimation(0,"counterB",false);
    unit:takeAnimationEffect(0,"counterB",false);
    return 1;
end

function class:endCounterB(unit)
    self.counterBFlag = false;
    return 1;
end

function class:startCounterA(unit)
    unit:takeAnimation(0,"counterA",false);
    unit:takeAnimationEffect(0,"counterA",false);
    return 1;
end

function class:endCounterA(unit)
    self.counterAFlag = false;
    return 1;
end

function class:takeSpecialEffect(unit)
    unit:addOrbitSystemCameraWithFile("../../effect/itemskill/itemskill2026","attack1",false);
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2027","attack2");
    orbit:takeAnimation(0,"attack2",true);
end

--=====================================================================================================================================
function class:receive3(args)
    self:HP80Trigger(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;