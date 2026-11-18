local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX化フォンギオン", version=1.3, id=100616});
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
    ATTACK5 = 1,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
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
    self.reverceMode = false;
    self.hitStopRegection = true;
    self.forceSkillNumber = 0;
    self.isReady = false
    self.posX = 0
    self.posY = 0
    event.unit:setSkillInvocationWeight(0);
    self.Clock = nil;
    self.HP_TRIGGERS = {
        [1] = {
            HP = 100,
            trigger = "stop",
            isActive = true
        },
        [2] = {
            HP = 75,
            trigger = "stop",
            isActive = true
        },
        [3] = {
            HP = 50,
            trigger = "endless",
            isActive = true
        },
        [4] = {
            HP = 40,
            trigger = "addRageBuff",
            isActive = true
        }

    }

    self.hpMarkers = {
        {
            HP = 75,isUsed = false,MARKER = event.unit:addNumHpMarker(0.75)
        },
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        },
        {
            HP = 40,isUsed = false,MARKER = event.unit:addNumHpMarker(0.4)
        }
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE or "攻撃力・命中率アップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.BUFF_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }


    self.CHARGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.CHARGE_MESSAGE or "周囲の時空が歪み始める！",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.REVERCE_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.REVERCE_MESSAGE1 or "時空は、我が手中にある…！",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.REVERCE_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.REVERCE_MESSAGE2 or "永遠に彷徨うがいい…！",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self:createClock(event.unit);
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    self:getDefaultPosition(event.unit)
    return 1;
end

function class:getDefaultPosition(unit)
    self.posX = unit:getPositionX()
    self.posY = unit:getPositionY()
    self.isReady = true
end

function class:setHPTriggers()
    self.HP_TRIGGERS = {
        [1] = {
            HP = 100,
            trigger = "stop",
            isActive = true
        },
        [2] = {
            HP = 75,
            trigger = "stop",
            isActive = true
        },
        [3] = {
            HP = 50,
            trigger = "endless",
            isActive = true
        },
        [4] = {
            HP = 25,
            trigger = "reverce",
            isActive = true
        }

    }
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    if self.hitStopRegection then
        event.unit:setReduceHitStop(20,1);
        event.unit:takeGrayScale(0.99);
    end
    if self.isReady then self:lockPosition(event.unit) end
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end

function class:lockPosition(unit)
    unit:setPosition(self.posX,self.posY)
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.reverceMode then
        attackIndex = 5;
    end
    
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
    event.unit:setBurstState(kBurstState_active);
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
        self:showMessages(unit,self.REVERCE_MESSAGES1);
    end

    if event.spineEvent == "reInit" then
        event.unit:setHP(event.unit:getCalcHPMAX());
        event.unit:setBreakPoint(event.unit:getBaseBreakCapacity());
        self:setHPTriggers();
        self.reverceMode = false;
        self:showMessages(unit,self.REVERCE_MESSAGES2);
    end

    if event.spineEvent == "addSP" then
        self:addSP(event.unit,self.spValue);
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

    for i,v in ipairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "stop" and self.forceSkillNumber == 0 and unit:getBurstState() ~= kBurstState_active then
        self:stopArts(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "endless" and self.forceSkillNumber == 0 and unit.m_breaktime <= 0 and unit:getBurstState() ~= kBurstState_active  then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end

    if trigger == "addRageBuff" then
        self:addRageBuff(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return true;
    end

    if trigger == "reverce" and self.forceSkillNumber == 0 and unit.m_breaktime <= 0 and unit:getBurstState() ~= kBurstState_active then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
        self:reverce(unit);
        return true;
    end
    return false;
end

function class:stopArts(unit)
    self.forceSkillNumber = 1;
    unit:addSP(unit:getNeedSP());
end

function class:addRageBuff(unit)
    self:showMessages(unit,self.BUFF_MESSAGES);
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
end

function class:reverce(unit)
    self.forceSkillNumber = 4;
    self.reverceMode = true;
    self:showMessages(unit,self.CHARGE_MESSAGES);
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self.isRage = true;
    self.forceSkillNumber = 3;
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
--エンドレスの演出関連
function class:endless(unit)
    local bg = unit:addOrbitSystemWithFile("50086endless","BG_ENDLESS");
    bg:setZOrder(2);
    unit:addOrbitSystemCameraWithFile("50086endless","FONT_ENDLESS",false);
    unit:addOrbitSystemWithFile("50086endless","CutIN_ENDLESS");
    local ef = unit:addOrbitSystem("endlessEF",0);
    ef:setDamageRateOffset(0.001);
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
    self.hitStopRegection = true;
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
            clock.object:setSetupAnimationName(""..clockTime.."to"..nextClockTime);
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
    self:stopArts(self.gameUnit);
    return 1;
end


function class:receive4(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:addRageBuff(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:reverce(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;