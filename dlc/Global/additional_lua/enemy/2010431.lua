local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="氷ドラゴン", version=1.3, id=2010431});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 0,
    ATTACK2 = 10,
    ATTACK3 = 10,
    ATTACK4 = 10,
    ATTACK5 = 0,
    ATTACK6 = 0
}

-- 使用する奥義とその確率
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
    ATTACK6 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    ORBIT = 8
}

-- HP50%以下時にかかるバフ内容
class.DAMAGE_UP_BUFF_ARGS = {
    {
        ID = 500121,
        EFID = 17,
        VALUE = 30,
        DURATION = 9999999,
        ICON = 26
    }
}

-- 定数
class.EFID_FREEZE = 96;
class.EFID_BURN = 97;
class.RAGE_COOLTIME = 25;
class.CHANGE_RAGE_ATTACK_INDEX = 5;
class.ORBIT_NAME_IN = "ice_floor_in";
class.ORBIT_NAME_LOOP = "ice_floor_cur";
class.ORBIT_NAME_OUT = "ice_floor_out";

function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.changeRageFlg = false;
    self.rageCooltime = 0;
    self.isFreeze = false;
    self.isBurn = false;
    self.orbitIce = nil;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [80] = "getRage",
        [50] = "damageUp"
    }

    self.hpMarkers = {
        [80] = self.gameUnit:addNumHpMarker(0.8),
        [50] = self.gameUnit:addNumHpMarker(0.5)
    }
    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "燃焼で怒り解除",
            COLOR = Color.cyan,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "魔法耐性ダウン",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    -- 怒り時のメッセージ
    self.RAGE_MESSAGES = {
        {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り状態：持続ダメージ",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    -- 怒り解除時のメッセージ
    self.RAGE_END_MESSAGES = {
        {
            MESSAGE = self.TEXT.RAGE_END_MESSAGE1 or "怒り状態解除",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    -- 氷結時メッセージ
    self.FREEZE_MESSAGES = {
        {
            MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "氷結中HP自然回復",
            COLOR = Color.cyan,
            DURATION = 5,
            ICON = 35
        }
    }

    -- 与ダメージUP時メッセージ
    self.DAMAGE_UP_MESSAGES = {
        {
            MESSAGE = self.TEXT.DAMAGE_UP_MESSAGE1 or "与ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    -- ヒットストップ軽減
    event.unit:setReduceHitStop(2, 0.7);
    -- 怒り状態クールタイム更新
    self:updateCooltime(event.deltaTime);
    -- 状態異常チェック
    self:checkCondition(event.unit);
    -- HPトリガーチェック
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:run(event)
    if event.spineEvent == "addSP" then self:addSP(event.unit); end
    if event.spineEvent == "addIce" then
        if self:getIsHost() then
            self:getRage(event.unit);
            self:startIce(event.unit);
            self:send(3,0);
        end
    end
    if event.spineEvent == "iceControll" then self:loopIce(event.unit); end
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.changeRageFlg then
        self.changeRageFlg = false;
        -- 非怒り状態&クールタイム終了&燃焼状態でなければ怒り状態移行
        if not self.isRage and self.rageCooltime <= 0 and not self.isBurn then
            attackIndex = self.CHANGE_RAGE_ATTACK_INDEX;
        end
    end

    unit:takeAttack(tonumber(attackIndex));
    self:send(1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    if not self.attackCheckFlg and self:getIsHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not self:getIsHost() and not self.fromHost then
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

    unit:takeSkill(tonumber(skillIndex));
    self:send(2,tonumber(skillIndex));
    return 0;
end

function class:takeSkill(event)
    if not self.skillCheckFlg and self:getIsHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not self:getIsHost() and not self.fromHost then
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
end

function class:getRage(unit)
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[80])
end

function class:endRage(unit)
    if not self.isRage then
        return;
    end

    self.isRage = false;
    self.rageCooltime = self.RAGE_COOLTIME;
    self:endIce(unit);
    self:showMessages(unit,self.RAGE_END_MESSAGES);
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
        if v.ICON == nil then
            Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
        else
            Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR,v.ICON);
        end
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
    if trigger == "getRage" then
        self.changeRageFlg = true;
        return false;
    end

    if trigger == "damageUp" and self:getIsHost() then
        self:addBuffs(unit,self.DAMAGE_UP_BUFF_ARGS);
        self:showMessages(unit,self.DAMAGE_UP_MESSAGES);
        self:send(4,0);
    end

    return true;
end

function class:updateCooltime(deltaTime)
    if self.isRage or self.rageCooltime <= 0 then
        return;
    end

    self.rageCooltime = self.rageCooltime - deltaTime;
    if self.rageCooltime < 0 then self.rageCooltime = 0; end
end

function class:checkCondition(unit)
    -- 氷結発生
    if not self.isFreeze then
        if unit:getTeamUnitCondition():findConditionWithType(self.EFID_FREEZE) ~= nil then
            self.isFreeze = true;
            self:showMessages(unit,self.FREEZE_MESSAGES);
        end
    -- 氷結解除
    else
        if unit:getTeamUnitCondition():findConditionWithType(self.EFID_FREEZE) == nil then
            self.isFreeze = false;
        end 
    end

    -- 燃焼発生
    if not self.isBurn then
        if unit:getTeamUnitCondition():findConditionWithType(self.EFID_BURN) ~= nil then
            self.isBurn = true;
            self:endRage(unit);
        end
    -- 燃焼解除
    else
        if unit:getTeamUnitCondition():findConditionWithType(self.EFID_BURN) == nil then
            self.isBurn = false;
        end
    end
end

function class:startIce(unit)
    if self.orbitIce ~= nil then
        return;
    end

    self.orbitIce = unit:addOrbitSystem(self.ORBIT_NAME_IN,0);
    self.orbitIce:takeAnimation(0,self.ORBIT_NAME_IN,true);
    self.orbitIce:setZOrder(0);
    self.orbitIce:setActiveSkill(self.ACTIVE_SKILLS.ORBIT);
end

function class:endIce(unit)
    if self.orbitIce == nil then
        return;
    end

    self.orbitIce:takeAnimation(0,self.ORBIT_NAME_OUT,false);
    self.orbitIce = nil;
end

function class:loopIce(unit)
    if self.orbitIce == nil then
        return;
    end

    self.orbitIce:takeAnimation(0,self.ORBIT_NAME_LOOP,true);
end

function class:send(number,param)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,number,param);
end

function class:receive3(args)
    self:getRage(self.gameUnit);
    self:startIce(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:addBuffs(self.gameUnit,self.DAMAGE_UP_BUFF_ARGS);
    self:showMessages(self.gameUnit,self.DAMAGE_UP_MESSAGES);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

class:publish();

return class;