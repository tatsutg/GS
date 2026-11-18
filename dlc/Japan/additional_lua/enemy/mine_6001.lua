local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="静聖神パルラミシア", version=1.3, id="mine_60001"});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 10,
    ATTACK2 = 10,
    ATTACK3 = 0,
    ATTACK4 = 0,
    ATTACK5 = 0,
    ATTACK6 = 0,
    ATTACK7 = 0,
    ATTACK8 = 0,
    ATTACK9 = 10
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 0,
    SKILL2 = 100,
    SKILL3 = 0,
    SKILL4 = 0,
    SKILL5 = 0
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
    SKILL5 = 14
}

-- 時間経過強化時にかかるバフ
class.BOOST_BUFF_ARGS = {
    -- 攻撃力アップ
    {
        ID = 600011,
        EFID = 13,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 3
    },
    -- ダメージアップ
    {
        ID = 600012,
        EFID = 17,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 26
    }
}

class.FORCE_SKILL_INDEX_NORMAL = 2;
class.FORCE_SKILL_INDEX_RAGE = 1;
class.BOOST_TIME_LIMIT = 180;
class.MESSAGE_TIME_LIMIT = 60;

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.isBoost = false;
    self.timer = 0;
    self.enableTimer = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "麻痺状態時以外ダメージ無効",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    -- 時間経過強化時メッセージ
    self.BOOST_MESSAGES = {
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.cyan,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.hitStopReduceRate = 1.0;

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    self.enableTimer = true;
    return 1;
end

function class:update(event)
    self:setReduceHitStop(event.unit);
    self:checkTimer(event.unit,event.deltaTime);
    self:checkBoost(event.unit);
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
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
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.isRage then
        skillIndex = self.FORCE_SKILL_INDEX_RAGE;
    else
        skillIndex = self.FORCE_SKILL_INDEX_NORMAL;
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
    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:getRage(unit)
    self.isRage = true;
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
            self:executeTrigger(unit,self.HP_TRIGGERS[i]);
            self.HP_TRIGGERS[i] = nil;
        end
    end
end

function class:executeTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
end

function class:setReduceHitStop(unit)
    unit:setReduceHitStop(2, self.hitStopReduceRate);
end

function class:checkBoost(unit)
    if self.isBoost then
        return;
    end

    local time = BattleControl:get():getTime();
    if time < self.BOOST_TIME_LIMIT then
        return;
    end

    self:addBuffs(unit,self.BOOST_BUFF_ARGS);
    self:showMessages(unit,self.BOOST_MESSAGES);
    self.isBoost = true;
end

function class:checkTimer(unit,deltaTime)
    if not self.enableTimer then
        return;
    end

    self.timer = self.timer + deltaTime;

    if self.timer < self.MESSAGE_TIME_LIMIT then
        return;
    end

    self:showMessages(unit,self.START_MESSAGES);
    self.timer = 0;
end

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

class:publish();

return class;