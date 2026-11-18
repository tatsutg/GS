local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ギアベール", version=1.6, id=1203015});
class:inheritFromUnit("bossBase");

class.ATTACK_REEL = {
    [1] = {
        ATTACK1 = 100,
        ATTACK4 = 100
    }
}

class.ATTACK_REEL2 = {
    [1] = {
        ATTACK7 = 100
    },
    [2] = {
        ATTACK8= 100
    },
    [3] = {
        ATTACK9 = 100
    },
    [4] = {
        ATTACK6= 100,
        ATTACK7= 100,
        ATTACK8= 100
    }
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
}

class.SKILL_WEIGHTS_RAGE = {
    SKILL2 = 100
}




--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 1,
    ATTACK3 = 1,
    ATTACK4 = 2,
    ATTACK5 = 3,
    ATTACK6 = 4,
    ATTACK7 = 5,
    ATTACK8 = 6,
    ATTACK9 = 7,
    ATTACK10 = 8,
    SKILL1 = 9,
    SKILL2 = 10
}

class.ANIMSTATE = {
    IDLE = "idle",
    DAMAGE = "damage"
}


--怒り時にかかるバフ内容
class.RAGE2_BUFF_ARGS = {
    {
        ID = 40001174,
        EFID = 13,         --攻撃アップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 3
    },
    {
        ID = 40001173,
        EFID = 17,         --与ダメ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40001175,
        EFID = 28,         --速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}

class.STAN_ARGS = {
    {
        ID = 40001176,
        EFID = 89,         --気絶
        VALUE = 1,        --効果量
        DURATION = 15,
        ICON = 79
    }
}

class.START_MESSAGES = {
    {
        MESSAGE = class.TEXT.START_MESSAGE1 or "闇属性耐性",
        COLOR = Color.yellow,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.START_MESSAGE2 or "魔族からの攻撃無効",
        COLOR = Color.yellow,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.START_MESSAGE3 or "神族・人族キラー",
        COLOR = Color.yellow,
        DURATION = 5
    }
};


class.RAGE2_MESSAGES = {
    {
        MESSAGE = class.TEXT.RAGE2_MESSAGE1 or "闇の中で…滅せよ……",
        COLOR = Color.magenta,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.RAGE2_MESSAGE2 or "攻撃力・与ダメージ・行動速度アップ",
        COLOR = Color.yellow,
        DURATION = 5
    }
};



--怒り時のメッセージ
class.RAGE_MESSAGES = {
    {
        MESSAGE = class.TEXT.RAGE_MESSAGE1 or "我を…冒涜した罪は…重い……",
        COLOR = Color.magenta,
        DURATION = 5
    }
};

class.DEAD_MESSAGES = {
    {
        MESSAGE = class.TEXT.DEAD_MESSAGE1 or "闇は……不滅……",
        COLOR = Color.magenta,
        DURATION = 5
    }
};

--===============================================================================================================================================
function class:start(event)
    event.unit:setAttackDelay(1);
    event.unit:setSPGainValue(0);
    self.isRage = false;
    event.unit:setNeedSP(100);
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.attack10Flag = false;
    self.attackCounter = 0;
    self.HP_TRIGGERS = {};
    event.unit:takeAnimation(1,"under_idle",true);
    self.deadFlag = false;
    self.specialStan = false;

    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(100,1);--ヒットストップ無効Lv2　100%軽減
    self:fixPosition(event.unit);
    return 1;
end


function class:takeIdle(event)
    self:switchAnimation(event.unit,self.ANIMSTATE.IDLE);
    return 1;
end

function class:takeDamage(event)
    self:switchAnimation(event.unit,self.ANIMSTATE.DAMAGE);
    return 1;
end

function class:takeDamageValue(event)
    if self.attack10Flag then
        return math.sqrt(event.value);
    end
    return event.value;
end

function class:excuteAction(event)
    if self.startPositionX == nil then
        self.startPositionX = event.unit:getPositionX();
        self.startPositionY = event.unit:getPositionY();
    end
    return 1;
end

function class:dead(event)
    if not self.deadFlag then
        event.unit:setHP(1);
        return 0;
    else
        event.unit:takeAnimation(1,"out",false);
        self:showMessages(event.unit,self.DEAD_MESSAGES);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
    end
    return 1;
end
function class:receive9(args)
    self:showMessages(self.gameUnit,self.DEAD_MESSAGES);
    return 1;
end

function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "rage" then return self:rage(event.unit) end
    return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self.attackCounter = self.attackCounter + 1;
    if tonumber(attackIndex) == 1 then
        local target = unit:getTargetUnit();
        local distance = 0;
        if taeget ~= nil then
            distance = BattleUtilities.getUnitDistance(unit,target);
        end
        if distance >= 400 then
            attackIndex = 3;
        elseif distance >= 200 then
            attackIndex = 2;
        else
            attackIndex = 1;
        end
    end
    if self.attack10Flag and not self.isRage then
        attackIndex = 10;
        self.specialStan = true;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    unit:takeAttack(tonumber(attackIndex));

    return 0;
end


function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        self.specialStan = true;
    end
    unit:takeSkill(tonumber(skillIndex));
    return 0;
end


function class:attackDamageValue(event)
    if not self.specialStan then
        return event.value;
    end
    --specialStanはホストしか立たないからここから先はホストのみの処理だよ！！
    local allUnits = {};


    for i=0,3 do
        local targetUnit = self:getPlayerUnit(i);
        if targetUnit ~= nil then
            table.insert(allUnits,targetUnit);
        end
    end

    local rand = Random.range(0,table.maxn(allUnits));

    self:execSpecialStan(allUnits[rand + 1]:getIndex());

    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,allUnits[rand + 1]:getIndex());--ここで同期投げてるよ！

    self.specialStan = false;

    return event.value;
end



function class:execSpecialStan(index)
    local targetUnit = self:getPlayerUnit(index);
    self:addBuff(targetUnit,self.STAN_ARGS[1]);
    targetUnit:setBurstPoint(0);
end

--===================================================================================================================

function class:fixPosition(unit)
    unit:getSkeleton():setPosition(0,0);
    if self.startPositionX ~= nil then
        unit:setPositionX(self.startPositionX);
        unit:setPositionY(self.startPositionY);
    end
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
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

    if unit:getHP() <= 1 and not self.deadFlag then
        self:HP0(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end

end

function class:excuteTrigger(unit,trigger)

    if trigger == "getRage2" then
        self:getRage2(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:rage(unit)
    if self:getIsHost() then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        self.attack10Flag = false;
    end
    return 1;
end

function class:getRage(unit)
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
    unit:setSetupAnimationName("idle2");
    self.deadFlag = true;
    self.attack10Flag = false;
    return 1;
end

function class:getRage2(unit)
    self:addRageBuff(unit);
    self:showMessages(unit,self.RAGE2_MESSAGES);
    self.deadFlag = true;--一応。不死身のギアベさんを爆誕させないように念には念を入れてこっちのフラグにも仕込んでおく。
    self.attack10Flag = false;
    return 1;
end

function class:HP0(unit)
    unit:setHP(unit:getCalcHPMAX() * 0.8);
    unit:takeDamage();
    self.attack10Flag = true;
    unit:setInvincibleTime(5);
    self.ATTACK_REEL = self.ATTACK_REEL2;
    self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_RAGE;
    self.HP_TRIGGERS = {
        [30] = "getRage2"
    };
end

function class:addRageBuff(unit)
    for i, v in ipairs(self.RAGE2_BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end

function class:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--===============================================================================================================================================

function class:switchAnimation(unit,state)
    if self.isRage then
        unit:setNextAnimationName(state.."2");
    end
    return 1;
end

--===============================================================================================================================================

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

--=====================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:getRage2(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:HP0(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:execSpecialStan(args.arg);
    return 1;
end


function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end


class:publish();

return class;