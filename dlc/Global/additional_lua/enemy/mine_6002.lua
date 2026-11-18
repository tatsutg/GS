local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="葬魂神オルデウス", version=1.3, id="mine_60002"});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 10,
    ATTACK2 = 10,
    ATTACK3 = 0,
    ATTACK4 = 10
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 0,
    SKILL3 = 0
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 1,
    SKILL1 = 4,
    SKILL2 = 6,
    SKILL3 = 5
}

-- 時間経過強化時にかかるバフ
class.BOOST_BUFF_ARGS = {
    -- 攻撃力アップ
    {
        ID = 600021,
        EFID = 13,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 3
    },
    -- ダメージアップ
    {
        ID = 600022,
        EFID = 17,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 26
    }
}

class.CONDITION_TYPE_CURSE = 95;
class.KILL_CURSE_SKILL_INDEX = 3;
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "物理耐性アップ",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    -- 時間経過強化時メッセージ
    self.BOOST_MESSAGES = {
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.magenta,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.magenta,
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
    if event.spineEvent == "death" then return self:death(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

function class:takeIdle(event)
    event.unit:setNextAnimationName("zcloneNidle");
    return 1;
end

function class:takeBack(event)
    return 1;
end

function class:takeDamage(event)
    event.unit:setNextAnimationName("zcloneNdamage");
    return 1;
end

function class:dead(event)
    event.unit:setNextAnimationName("zcloneNout");
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
    if event.index ~= 3 then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    local targets = self:getUnitCurse();
    -- 対象となるユニットが1体以上存在すれば指定の奥義を使用する
    if targets ~= nil and #targets > 0 then
        skillIndex = self.KILL_CURSE_SKILL_INDEX;
        unit:setInvincibleTime(10);
        self:generalPause(unit);
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
    if event.index ~= 3 then event.unit:setNextAnimationName("zcloneNskill" .. event.index); end
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

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:generalPause(unit)
            
    --まずヒットストップ中のユニットのヒットストップを解除　そして全員気絶
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:resumeUnit();
            uni:getTeamUnitCondition():addCondition(-60002,89,100,10,0);
        end
    end

    --死神だけ動く
    unit:resumeUnit();
    unit.m_IgnoreHitStopTime = 10;

end

function class:death(unit)
    local targets = self:getUnitCurse();

    local unit = nil;
    for i = 1, #targets do
        unit = targets[i];
        if unit ~= nil then
            unit:setHP(0);
        end
    end

    return 1;
end

-- 指定のバフが掛かっているユニットをリストで取得する関数
function class:getUnitCurse()
    -- 指定のバフが掛かっているかどうかを判定する関数
    local callback = function(unit,index)
        return Utility.getUnitBuffByType(unit,self.CONDITION_TYPE_CURSE);
    end
    return { Utility.findUnitsByCallBack(callback) };
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