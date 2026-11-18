local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2013429});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 0,
    SKILL2 = 100,
    SKILL3 = 0,
    SKILL4 = 0
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 5,
    SKILL3 = 5,
    SKILL4 = 5
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 98,         --バリア
        VALUE = 300000,        --効果量
        DURATION = 9999999,
        ICON = 24,
        EFFECT = 1
    }
}

class.RAGE_BUFF_ARGS2 = {
    {
        ID = 40076,
        EFID = 13,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 3
    },
    {
        ID = 40076,
        EFID = 28,         --ダメージアップ
        VALUE = 20,        --効果量
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
    self.isRage = false;
    self.stopOrbit = nil;
    self.isStop = false;
    self.hitStopRegection = false;
    self.forceSkillNumber = 0;
    event.unit:setSkillInvocationWeight(0);
    self.Clock = nil;
    self:setHPTriggers();

    --怒り時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.RAGE_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGES1_1 or "ダメージ３０万無効化",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGES1_2 or "ダメージ無効化中ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.RAGE_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGES2_1 or "攻撃力アップ",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGES2_2 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self:createClock(event.unit);
    return 1;
end

function class:startWave(event)
    self.posX = event.unit:getPositionX()
    self.posY = event.unit:getPositionY()
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:setHPTriggers()
    self.HP_TRIGGERS = {
        -- [70] = "addBarrire",
        -- [40] = "addBarrire",
        -- [20] = "addBuff"
    }
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    -- if self.hitStopRegection then
        event.unit:setReduceHitStop(20,1);
        event.unit:takeGrayScale(0.99);
    -- end
    if self.posX ~= nil then
        event.unit:setPosition(self.posX,self.posY)
    end
    return 1;
end

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
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.forceSkillNumber ~= 0 then
        skillIndex = self.forceSkillNumber;
        self.forceSkillNumber = 0;
    end
    unit:takeSkill(tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;

    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:attackDamageValue(event)
    if self.isStop then
        self:theWorld(event.enemy);
    end
    return event.value;
end

function class:takeDamage(event)
    self:canselled();
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:run(event)
    if event.spineEvent == "endless" then
        self:endless(event.unit);
    end
    if event.spineEvent == "cameraControll" then
        self:cameraControll(event.unit);
    end

    if event.spineEvent == "showStopOrbit" then
        self:showStopOrbit(event.unit);
    end

    if event.spineEvent == "stop" then
        self:stop(event.unit);
    end

    if event.spineEvent == "reStart" then
        self:restart(event.unit);
    end

    if event.spineEvent == "clockAttack" then
        self.Clock:takeAttack();
    end

    if event.spineEvent == "tickEnd" then
        self.Clock:tick();
    end

    if event.spineEvent == "clockActionEnd" then
        self.Clock:takeBaseAnimation();
    end

    if event.spineEvent == "reverce" then
        self.Clock:setVector(-1);
        self.Clock:takeSkill4();
    end

    if event.spineEvent == "reInit" then
        event.unit:setHP(event.unit:getCalcHPMAX());
        self:setHPTriggers();
    end

    if event.spineEvent == "reverceEnd" then
        self.Clock:setVector(1);
    end

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
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "stop" and self.forceSkillNumber == 0 then
        self.forceSkillNumber = 1;
        unit:addSP(unit:getNeedSP());
        return true;
    end
    if trigger == "endless" and self.forceSkillNumber == 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "reverce" and self.forceSkillNumber == 0 then
        self.forceSkillNumber = 4;
        return true;
    end

    if trigger == "addBarrire" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true
    end

    if trigger == "addBuff" then
        self:getRage2(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true
    end

    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES1);
end

function class:getRage2(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS2);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES2);

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
--エンドレスの演出関連
function class:endless(unit)
    local bg = unit:addOrbitSystemWithFile("50086endless","BG_ENDLESS");
    bg:setZOrder(2);
    unit:addOrbitSystemCameraWithFile("50086endless","FONT_ENDLESS",false);
    unit:addOrbitSystemWithFile("50086endless","CutIN_ENDLESS");
    local ef = unit:addOrbitSystem("endlessEF",0);
    ef:setZOrder(9000);
    self.Clock:takeEndless();

end

function class:cameraControll(unit)
    unit:cameraLock(0,0.2,unit:getSkeleton():getBoneWorldPositionX("MAIN"),unit:getSkeleton():getBoneWorldPositionY("MAIN") -250);
end

--=====================================================================================================================================
--時止め関連

function class:showStopOrbit(unit)
    self.stopOrbit = unit:addOrbitSystem("skill1orbit",0);
    self.stopOrbit:setZOrder(2);
    self.hitStopRegection = true;
end

function class:stop(unit)
    self.isStop = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,92,100,13,0);
            uni:takeGrayScale(0.1);
            uni:takeHitStop(13);
        end
    end
end

function class:theWorld(unit)
    unit:takeGrayScale(0.1);
end

function class:canselled()
    self.isStop = false;
    if self.stopOrbit ~= nil then
        self.stopOrbit:takeAnimation(0,"skill1orbitCansel",false);
        self.stopOrbit = nil;
    end
    self:restart();
end

function class:restart()
    self.hitStopRegection = false;
    self.stopOrbit = nil;
    self.isStop = false;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:takeGrayScale(0.99);
        end
    end
end

--=====================================================================================================================================
--背後の時計関係
function class:createClock(unit)
    self.Clock = {
        object = nil,
        vector = 1,
        count = 0,

        setUp = function(clock)
            clock.object:takeAnimation(0,"base",true);
            clock.object:setZOrder(3);
            clock.object:setPosition(-260,-30);
        end,

        takeBaseAnimation = function(clock)
            clock.object:takeAnimation(0,"base",true);
        end,

        setVector = function(clock,vec)
            clock.vector = vec;
        end,

        tick = function(clock)
            local clockTime = clock.count%12;
            local nextClockTime = (clock.count + clock.vector)%12;
            clock.object:takeAnimation(1,""..clockTime.."to"..nextClockTime,false);
            clock.count = clock.count + clock.vector;
        end,

        takeAttack = function(clock)
            clock.object:takeAnimation(0,"attack3",true);
        end,

        takeEndless = function(clock)
            clock.object:takeAnimation(0,"skill3",true);
        end,

        takeSkill4 = function(clock)
            clock.object:takeAnimation(0,"skill4",true);
        end

    }
    self.Clock.object = unit:addOrbitSystemWithFile("50086Clock","base");
    self.Clock:setUp();
    self.Clock:tick();
end

--=====================================================================================================================================

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:getRage2(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;