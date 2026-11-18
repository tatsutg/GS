local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="被験体β－３", version=1.3, id="600000033"});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 20,
    ATTACK2 = 15,
    ATTACK3 = 15,
    ATTACK4 = 0,
    ATTACK5 = 10,
    ATTACK6 = 40
}


-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 70,
    SKILL2 = 30
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 4,
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

class.HP50_BUFF = {
    {
        ID = 6000034,
        EFID = 28, --攻撃速度
        VALUE = 30,
        DURATION = 99999,
        ICON = 7
    }
}

class.HP30_BUFF = {
    {
        ID = -6000035,
        EFID = 17, --ダメージ
        VALUE = 50,
        DURATION = 99999,
        ICON = 26
    }
}


  -- ブレイク耐性
class.BREAK_RESISTANCE_LIST = {
    {
      ID = 5013315131,
      EFID = 27,
      VALUE = 20,
      DURATION = 99999,
      ICON = 0
    },
    {
      ID = 5013315133,
      EFID = 27,
      VALUE = 40,
      DURATION = 99999,
      ICON = 0
    },
    {
      ID = 5013315134,
      EFID = 27,
      VALUE = 80,
      DURATION = 99999,
      ICON = 0
    }
}

class.TARGET_BUFF_BOX_LIST = {
      {
      ID = 5013315135,
      EFID = 17, -- ダメージ
      VALUE = 100,
      DURATION = 999999,
      ICON = 26
    }
}


class.GET_RAGE_ATTACK_INDEX = 5;

class.PROTECT_ID = 128
class.DEBUFF_ID_LIST = {89,90,91,92,93,94,95,96,97}
class.TELOP_SPAN = 30


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

    self.hitStop = 0.8
    self.showedBuff = false
    self.showedDebuff = false
    self.telopTimer = 0


    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [50] = "getRage",
        [30] = "getFury"
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "状態異常の数だけ被ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "相手が庇うとダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE3 or "炎属性キラー・命中率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP50_MESSAGE = {
        {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5           
        }
    }

    self.HP30_MESSAGE = {
        {
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5                       
        }
    }

    self.PROTECT_MESSAGE = {
        {
            MESSAGE = self.TEXT.PROTECT_MESSAGE1 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5                       
        }
    }

    self.DEBUFF_MESSAGE = {
        {
            MESSAGE = self.TEXT.DEBUFF_MESSAGE1 or "被ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5                       
        }
    }

    -- レイドメッセージ
    self.RAID_MESSAGES = {
        {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.yellow,
            DURATION = 5
        }        
    }

    -- テロップ
    self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"

    local floor = megast.Battle:getInstance():getCurrentMineFloor();

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end                
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
    self.enableTimer = true;
    return 1;
end

function class:update(event)
    event.unit:setReduceHitStop(2,self.hitStop)
    self:HPTriggersCheck(event.unit);
    self:updateGlab(event.unit,event.deltaTime);
    self:telop(event.deltaTime)

    self:checkProtect()
    self:checkDebuff(event.unit)
    return 1;
end

function class:checkProtect()
    if not self.showedBuff then
        for i = 0,3 do
            local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
            if localUnit ~= nil then
                local checkUnit = localUnit:getTeamUnitCondition():findConditionWithType(self.PROTECT_ID)
                if checkUnit ~= nil then
                    self.showedBuff = true
                    self:showMessages(self.gameUnit,self.PROTECT_MESSAGE)
                    break
                end
            end
        end
    end
end

function class:checkDebuff(unit)
    if not self.showedDebuff then
        for i in pairs(self.DEBUFF_ID_LIST) do
            local teamUnit = unit:getTeamUnitCondition():findConditionWithType(self.DEBUFF_ID_LIST[i])
            if teamUnit ~= nil then
                self.showedDebuff = true
                self:showMessages(self.gameUnit,self.DEBUFF_MESSAGE)
                break
            end
        end
    end
end

function class:run(event)
    if event.spineEvent == "glabCheckStart" then return self:glabCheckStart(event.unit); end
    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
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

    if self.isCatched then
        if event.enemy:getIndex() == self.chatchedIndex then
            self.isCatched = false
            self.chatchedIndex = nil
            return event.enemy:getHP() -1
        end
        return 1
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

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)
    self.isCatched = false
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
    if not self.isRage and event.index ~= 5 then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
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
    self.isCatched = false
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

    -- local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    -- unit:takeHitStop(0.5);
    -- orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    -- orbitHit:setTargetUnit(target);
    -- orbitHit:setHitType(2);
    -- orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK4);
    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    -- self.glabIndex = nil;

    -- レイド用。投げられたユニットは強制的にHP1になる。
    self.isCatched = true
    self.chatchedIndex = self.glabIndex
    self.glabIndex = nil
    target = nil
    -- orbitHit:setDamageRateOffset(0)
    -- target:setHP(1)

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

    -- self:addBuffs(unit,self.GLAB_SELF_BUFF_ARGS);
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

function class:getRage(unit)
    -- self.isRage = true;
    -- self.getRageFlg = true;
    self.hitStop = 1
    self:addBuffs(self.gameUnit,self.HP50_BUFF)
    self:showMessages(self.gameUnit,self.HP50_MESSAGE)
end

function class:getFury()
    self:addBuffs(self.gameUnit,self.HP30_BUFF)
    self:showMessages(self.gameUnit,self.HP30_MESSAGE)
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

-- ---------------------------------------------------------------------------------
-- -- executeAction
-- ---------------------------------------------------------------------------------
function class:excuteAction(event)
  self:checkTarget()
  self:checkBreak(event.unit)

  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:addBuffs(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
    self:showMessages(self.gameUnit,self.RAID_MESSAGES)
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

function class:checkBreak(unit)
  if not megast.Battle:getInstance():isRaid() then
    return;
  end

  if RaidControl:get():getRaidBreakCount() >= 1 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST[1])
  end
  if RaidControl:get():getRaidBreakCount() >= 2 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST[2])
  end
  if RaidControl:get():getRaidBreakCount() >= 3 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST[3])
  end
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

    if trigger == "getFury" then
        self:getFury()
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