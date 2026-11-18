local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="被験体γ－３", version=1.3, id=500891213});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 25,
    ATTACK2 = 25,
    ATTACK3 = 0,
    ATTACK4 = 25,
    ATTACK5 = 0
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
    SKILL1 = 6,
    SKILL2 = 7
}

-- 掴み時に自身にかかるバフ内容
class.GLAB_SELF_BUFF_ARGS = {
    {
        ID = -11,
        EFID = 113,
        VALUE = 500,
        DURATION = 2000,
        ICON = 0
    }
}

-- 掴み時に対象にかかるバフ内容
class.GLAB_TARGET_BUFF_ARGS = {
    {
        ID = -10,
        EFID = 89,
        VALUE = 1,
        DURATION = 14,
        ICON = 0
    }
}

-- 開幕封印
class.START_BUFF_ARGS = {
    {
        ID = -12,
        EFID = 92,
        VALUE = 100,
        DURATION = 3,
        ICON = 82
    }
}

-- 時間経過強化時にかかるバフ
class.BOOST_BUFF_ARGS = {
    -- 攻撃力アップ
    {
        ID = 500051,
        EFID = 13,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 3
    },
    -- ダメージアップ
    {
        ID = 500052,
        EFID = 17,
        VALUE = 500,
        DURATION = 9999999,
        ICON = 26
    }
}

class.GET_RAGE_ATTACK_INDEX = 5;
class.BOOST_TIME_LIMIT = 180;
class.ATTACK3_SPAN = 15;
class.FIXED_DAMAGE_VALUE = 500;

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = false;
    self.getRageFlg = false;
    self.glabIndex = nil;
    self.hitList = {};
    self.checkGlab = false;
    self.isBoost = false;
    self.timer = 0;
    self.SLICE_RATIO = 0.25
    self.isAttack3 = false;
    self.isFixed = false;
    self.HP_TRIGGERS = {
        -- [50] = "getRage",
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "ダメージ無効化解除",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    -- 時間経過強化時メッセージ
    -- self.BOOST_MESSAGES = {
    --     {
    --         MESSAGE = self.TEXT.BOOST_MESSAGE1 or "攻撃力アップ",
    --         COLOR = Color.magenta,
    --         DURATION = 5
    --     },
    --     {
    --         MESSAGE = self.TEXT.BOOST_MESSAGE2 or "与ダメージアップ",
    --         COLOR = Color.magenta,
    --         DURATION = 5
    --     }
    -- }

    local floor = megast.Battle:getInstance():getCurrentMineFloor();
    -- 5階層毎にヒットストップ耐性20％上昇(最大100％)
    -- self.hitStopReduceRate = math.floor((floor - 1) / 5) * 0.2;
    -- if self.hitStopReduceRate > 1.0 then self.hitStopReduceRate = 1.0; end

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    -- self:setReduceHitStop(event.unit);
    self:checkTimer(event.unit,event.deltaTime);
    -- self:checkBoost(event.unit);
    self:HPTriggersCheck(event.unit);
    self:updateGlab(event.unit,event.deltaTime);
    return 1;
end

function class:run(event)
    if event.spineEvent == "glabCheckStart" then return self:glabCheckStart(event.unit); end
    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    if event.spineEvent == "sliceHP" then self:sliceHP(); end
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
    self:glabEnd(event.unit);
    return 1;
end

function class:attackDamageValue(event)
    if self.checkGlab then self:checkHit(event.enemy:getIndex()); end
    if self.isFixed then
        return self.FIXED_DAMAGE_VALUE;
    end
    return event.value;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.getRageFlg then
        self.getRageFlg = false;
        attackIndex = self.GET_RAGE_ATTACK_INDEX;
    end

    if self.isAttack3 then
        attackIndex = 3;
        self.isAttack3 = false;
    end

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    self.isFixed = false;
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
    if event.index == 3 then
        self.isFixed = true;
    end
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
    self.isFixed = false;
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
    if not self.isRage then event.unit:setNextAnimationName("zcloneNskill" .. event.index); end
    return 1;
end

function class:glabCheckStart(unit)
    self.checkGlab = true;
    self.hitList = {};
    return 1;
end

function class:tryGlab(unit)
    self.checkGlab = false;
    if not self:getIsHost() then
        return 1;
    end

    local targetIndex = Random.sample(self.hitList);

    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:glabEnd(unit)
    if self.glabIndex == nil then
        return 1;
    end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then
        self.glabIndex = nil;
        return 1;
    end

    local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    unit:takeHitStop(0.5);
    orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    orbitHit:setTargetUnit(target);
    orbitHit:setHitType(2);
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK4);

    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:checkHit(enemyIndex)
    for i = 1, #self.hitList do
        if self.hitList[i] == enemyIndex then return; end
    end
    table.insert(self.hitList,enemyIndex);
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    self:addBuffs(unit,self.GLAB_SELF_BUFF_ARGS);
    self:addBuffs(target,self.GLAB_TARGET_BUFF_ARGS);

    self.glabIndex = targetIndex;
end

function class:updateGlab(unit,deltaTime)
    if self.glabIndex == nil then
        return;
    end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then
        return;
    end

    local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");

    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
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
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.timer = self.timer + deltaTime;

    if self.timer < self.ATTACK3_SPAN then
        return;
    end

    self.isAttack3 = true;
    self.timer = 0;
end

function class:getRage(unit)
    self.isRage = true;
    self.getRageFlg = true;
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

--===================================================================================================================
-- HPトリガー
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

--===================================================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

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

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

function class:sliceHP()
   for i = 0,3 do
      local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil then
         local shavedHPValue = localUnit:getHP() - (localUnit:getCalcHPMAX() * self.SLICE_RATIO)
         localUnit:setHP(shavedHPValue)
         self:addBuffs(localUnit,self.START_BUFF_ARGS);
      end  
   end

end
--=====================================================================================================================================

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:execGlab(self.gameUnit,args.arg);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;