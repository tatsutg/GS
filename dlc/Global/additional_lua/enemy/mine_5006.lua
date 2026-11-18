local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="光神龍フォスラディウス", version=1.3, id="mine_50006"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 0,
    ATTACK2 = 10,
    ATTACK3 = 10,
    ATTACK4 = 10,
    ATTACK5 = 0
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1_1 = 6,
    SKILL1_2 = 7,
    SKILL2 = 8
}

--時間経過強化時にかかるバフ
class.BOOST_BUFF_ARGS = {
    -- 攻撃力アップ
    {
        ID = 500011,
        EFID = 13,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 3
    },
    -- ダメージアップ
    {
        ID = 500012,
        EFID = 17,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 26
    }
}

class.START_BUFF_ARGS = {
    -- 速度アップ
    {
        ID = 500014,
        EFID = 28,
        VALUE = 30,
        DURATION = 9999999,
        ICON = 0
    }
}

class.FIRE_PILLER_POSITIONS = {
    {X = 0,   Y = -150},
    {X = 300, Y =    0},
    {X = 100, Y =  100}
}

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
    self.firePillerIndex = 1;
    self.timer = 0;
    self.enableTimer = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "奥義ダメージ軽減",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    -- 時間経過強化時メッセージ
    self.BOOST_MESSAGES = {
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.red,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    local floor = megast.Battle:getInstance():getCurrentMineFloor();
    -- 5階層毎にヒットストップ耐性20％上昇(最大100％)
    self.hitStopReduceRate = math.floor((floor - 1) / 5) * 0.2;
    if self.hitStopReduceRate > 1.0 then self.hitStopReduceRate = 1.0; end

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSetupAnimationName("setUpNormal");
    return 1;
end

function class:startWave(event)
    self:showMessages(unit,self.START_MESSAGES);
    self:addBuffs(event.unit,self.START_BUFF_ARGS);
    self.enableTimer = true;
    return 1;
end

function class:update(event)
    self:setReduceHitStop(event.unit);
    self:checkTimer(event.unit,event.deltaTime);
    self:checkBoost(event.unit);
    return 1;
end

function class:run(event)
    if event.spineEvent == "setFire" then return self:setFire(event.unit) end
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

function class:takeIdle(event)
    if not self.isRage then event.unit:setNextAnimationName("zcloneNidle"); end
    return 1;
end

function class:takeBack(event)
    if not self.isRage then event.unit:setNextAnimationName("zcloneNback"); end
    return 1;
end

function class:takeDamage(event)
    if not self.isRage then event.unit:setNextAnimationName("zcloneNdamage"); end
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
    if not self.isRage then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

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
    if event.index == 1 then self.firePillerIndex = 1; end

    self:skillActiveSkillSetter(event.unit,event.index);
    if not self.isRage then event.unit:setNextAnimationName("zcloneNskill" .. event.index); end
    return 1;
end

function class:skillActiveSkillSetter(unit,index)
    local suffix = not self.isRage and 1 or 2;
    if index == 1 then
        unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index.."_"..suffix]);
    else
        unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
    end
end

function class:setFire(unit)
    if not self.isRage then return 1; end

    local orbitFirePiller = unit:addOrbitSystem("firePiller",0);
    local position = self.FIRE_PILLER_POSITIONS[self.firePillerIndex];
    if position ~= nil then orbitFirePiller:setPosition(position.X,position.Y); end
    orbitFirePiller:setAutoZoder(true);
    self.firePillerIndex = self.firePillerIndex + 1;
    
    unit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK1);
    return 1;
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
    unit:setSetupAnimationName("setUpFire");
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