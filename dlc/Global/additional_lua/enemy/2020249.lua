--@additionalEnemy,2020250
--@additionalItem,160002500
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="被験体β－３", version=1.3, id=2020249});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 25,
    ATTACK2 = 25,
    ATTACK3 = 25,
    ATTACK4 = 25,
    ATTACK5 = 0
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50
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

-- 時間経過強化時にかかるバフ
class.BOOST_BUFF_ARGS1 = {
    -- 攻撃力アップ
    {
        ID = -500051,
        EFID = 12,
        VALUE = 250,
        DURATION = 9999999,
        ICON = 3
    }
}

class.BOOST_BUFF_ARGS2 = {

    -- ダメージアップ
    {
        ID = -500052,
        EFID = 17,
        VALUE = 30,
        DURATION = 9999999,
        ICON = 26
    }
}

class.SUMMON_WAITS = {
    [2020250] = 20
}

class.GET_RAGE_ATTACK_INDEX = 5;
class.BOOST_TIME_LIMIT = 15;
class.BOOST_TIME_LIMIT2 = 30;
class.MESSAGE_TIME_LIMIT = 30;
class.SUMMON_TIME_LIMIT = 60;
class.SPECIAL_ATTACK_TIME_LIMIT = 45;
class.SPECIAL_ARTS_TIME_LIMIT = 45;
class.SHOWING_TIME_LIMIT = 4;

class.ITEM_ID = 160002500;

class.BORDER1 = 90;
class.BORDER2 = 120;
class.BORDER3 = 180;
class.BORDER4 = 240;
class.BORDER5 = 300;
class.BORDER6 = 360;
class.BORDER7 = 420;
class.BORDER8 = 480;
class.BORDER9 = 540;
class.BORDER10 = 600;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.isRage = true;
    self.getRageFlg = false;
    self.glabIndex = nil;
    self.hitList = {};
    self.checkGlab = false;
    self.isBoost = false;
    self.messageTimer = 0;
    self.boostTimer1 = 0;
    self.boostTimer2 = 0;
    self.summonTimer = 0;
    self.specialAttackTimer = 22;
    self.specialArtsTimer = 0;
    self.showingTimer = 0;
    self.totalTimer = 0;
    self.forceAttackIndex = 0;
    self.forceSkillIndex = 0;
    self.isEnd = false;
    self.isWin = false;
    self.enableTimer = false;
    event.unit:setSkillInvocationWeight(0);
    BattleControl:get():setBreakBarEnable(false);
    event.unit:setItemSkill(0, self.ITEM_ID)
    self.HP_TRIGGERS = {
        
    }

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "１分３０秒以上生き残れ！！",
            COLOR = Color.yellow,
            DURATION = 8
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイク無効",
            COLOR = Color.yellow,
            DURATION = 8
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE3 or "攻撃力・命中率アップ",
            COLOR = Color.yellow,
            DURATION = 8
        }

    }

    self.TIME_MESSAGES = {
        {
            MESSAGE = self.TEXT.TIME_MESSAGE1 or "%d分%d秒経過",
            COLOR = Color.cyan,
            DURATION = 8
        }
    }

    self.END_MESSAGES = {
        {
            MESSAGE = self.TEXT.END_MESSAGE1 or "%d分%d秒間耐え抜いた！！",
            COLOR = Color.red,
            DURATION = 8
        }
    }

    -- 時間経過強化時メッセージ
    self.BOOST_MESSAGES1 = {
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.yellow,
            DURATION = 8
        }
    }

    self.BOOST_MESSAGES2 = {
        {
            MESSAGE = self.TEXT.BOOST_MESSAGE2 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 8
        }
    }

    self.SPECIAL_ARTS_MESSAGES = {
        {
            MESSAGE = self.TEXT.SPECIAL_ARTS_MESSAGE or "被ダメージアップ攻撃",
            COLOR = Color.yellow,
            DURATION = 8
        }
    }

    self.SUMMON_MESSAGES = {
        {
            MESSAGE = self.TEXT.SUMMON_MESSAGE or "みきゅみきゅ！！",
            COLOR = Color.cyan,
            DURATION = 8
        }
    }

    self.BORDER1_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER1_MESSAGE or "１分３０秒に届かなかった……",
            COLOR = Color.magenta,
            DURATION = 8
        }
    }

    self.BORDER2_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER2_MESSAGE or "パール級の耐久力！",
            COLOR = Color.green,
            DURATION = 8
        }
    }


    self.BORDER3_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER3_MESSAGE or "コーラル級の耐久力！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER4_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER4_MESSAGE or "オブシディアン級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER5_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER5_MESSAGE or "チタン級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER6_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER6_MESSAGE or "ターコイズ級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER7_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER7_MESSAGE or "ガーネット級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER8_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER8_MESSAGE or "アメジスト級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER9_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER9_MESSAGE or "エメラルド級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER10_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER10_MESSAGE or "ルビー級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.BORDER11_MESSAGES = {
        {
            MESSAGE = self.TEXT.BORDER11_MESSAGE or "ダイヤモンド級の耐久力！！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.hitStopReduceRate = 0.8;

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
    self:checkBoost(event.unit,event.deltaTime);
    self:checkBoost2(event.unit,event.deltaTime);
    self:checkSummon(event.unit,event.deltaTime);
    self:checkSpecialAttack(event.unit,event.deltaTime);
    self:checkSpecialArts(event.unit,event.deltaTime);
    self:showingCountDown(event.unit,event.deltaTime);
    self:HPTriggersCheck(event.unit);
    self:updateGlab(event.unit,event.deltaTime);

    return 1;
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

function class:takeBreakeDamageValue(event)
    return 0;
end

function class:attackDamageValue(event)
    if self.checkGlab then self:checkHit(event.enemy:getIndex()); end
    return event.value;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    if self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end

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
    if event.index == 5 then
        event.unit:takeItemSkill(0)
    end
    if not self.isRage then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkill(event)
    self:glabEnd(event.unit);
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

function class:checkBoost(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.boostTimer1 = self.boostTimer1 + deltaTime;

    if self.boostTimer1 < self.BOOST_TIME_LIMIT then
        return;
    end

    self.boostTimer1 = 0;

    self:addBuffs(unit,self.BOOST_BUFF_ARGS1);
    self:showMessages(unit,self.BOOST_MESSAGES1);
    
end

function class:checkBoost2(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.boostTimer2 = self.boostTimer2 + deltaTime;

    if self.boostTimer2 < self.BOOST_TIME_LIMIT2 then
        return;
    end

    self.boostTimer2 = 0;

    self:addBuffs(unit,self.BOOST_BUFF_ARGS2);
    self:showMessages(unit,self.BOOST_MESSAGES2);
    
end

function class:checkSpecialArts(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.specialArtsTimer = self.specialArtsTimer + deltaTime;

    if self.specialArtsTimer < self.SPECIAL_ARTS_TIME_LIMIT then
        return;
    end

    self.specialArtsTimer = 0;

    self.forceSkillIndex = 2;
    unit:addSP(100);
    self:showMessages(unit,self.SPECIAL_ARTS_MESSAGES);
    
end

function class:checkSpecialAttack(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.specialAttackTimer = self.specialAttackTimer + deltaTime;

    if self.specialAttackTimer < self.SPECIAL_ATTACK_TIME_LIMIT then
        return;
    end

    self.specialAttackTimer = 0;

    self.forceAttackIndex = 5;
    
end

function class:checkSummon(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    self.summonTimer = self.summonTimer + deltaTime;

    if self.summonTimer < self.SUMMON_TIME_LIMIT then
        return;
    end

    self.summonTimer = 0;

    self:summon(unit);
    
    
end

function class:checkTimer(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    self.totalTimer = self.totalTimer + deltaTime;
    self.messageTimer = self.messageTimer + deltaTime;

    if self.messageTimer < self.MESSAGE_TIME_LIMIT then
        return;
    end
    local min = math.floor(self.totalTimer/60);
    local sec = math.floor(self.totalTimer%60);
    self.TIME_MESSAGES[1].MESSAGE = self.TEXT.TIME_MESSAGE1 or "%d分%d秒経過";
    self.TIME_MESSAGES[1].MESSAGE = string.format(self.TIME_MESSAGES[1].MESSAGE,min,sec);
    self:showMessages(unit,self.TIME_MESSAGES);
    self.messageTimer = 0;
end

function class:showingCountDown(unit,deltaTime)
    if not self.isEnd then
        return;
    end

    self.showingTimer = self.showingTimer + deltaTime;

    if self.showingTimer < self.SHOWING_TIME_LIMIT then
        return;
    end

    self.showingTimer = 0;

    self:toResult();
    
end

function class:endWave(event)
    if not self.isEnd then
        self:gameEnd(event.unit);
        return 0;
    end
    return 1;
end


function class:gameEnd(unit)
    self.isEnd = true;
    local min = math.floor(self.totalTimer/60);
    local sec = math.floor(self.totalTimer%60);
    self.END_MESSAGES[1].MESSAGE = string.format(self.END_MESSAGES[1].MESSAGE,min,sec);
    self:showMessages(unit,self.END_MESSAGES);
    megast.Battle:getInstance():setBattleState(kBattleState_none);
    self.isWin = true;
    if self.totalTimer < self.BORDER1 then
        self:showMessages(unit,self.BORDER1_MESSAGES);
        self.isWin = false;
    elseif self.totalTimer < self.BORDER2 then
        self:showMessages(unit,self.BORDER2_MESSAGES);
    elseif self.totalTimer < self.BORDER3 then
        self:showMessages(unit,self.BORDER3_MESSAGES);
    elseif self.totalTimer < self.BORDER4 then
        self:showMessages(unit,self.BORDER4_MESSAGES);
    elseif self.totalTimer < self.BORDER5 then
        self:showMessages(unit,self.BORDER5_MESSAGES);
    elseif self.totalTimer < self.BORDER6 then
        self:showMessages(unit,self.BORDER6_MESSAGES);
    elseif self.totalTimer < self.BORDER7 then
        self:showMessages(unit,self.BORDER7_MESSAGES);
    elseif self.totalTimer < self.BORDER8 then
        self:showMessages(unit,self.BORDER8_MESSAGES);
    elseif self.totalTimer < self.BORDER9 then
        self:showMessages(unit,self.BORDER9_MESSAGES);
    elseif self.totalTimer < self.BORDER10 then
        self:showMessages(unit,self.BORDER10_MESSAGES);
    else
        self:showMessages(unit,self.BORDER11_MESSAGES);
    end
end

function class:toResult()
    megast.Battle:getInstance():waveEnd(self.isWin);
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



function class:summon(unit)
    for i = 1,5 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local newUnit = unit:getTeam():addUnit(i,summoner.Random.sampleWeighted(self.SUMMON_WAITS));--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            newUnit:setBaseHP(self:calcHP(self.totalTimer));
            newUnit:setHP(self:calcHP(self.totalTimer));
            self:showMessages(unit,self.SUMMON_MESSAGES);
            return;
        end
    end
end

function class:calcHP(time)
    local hp = time * time * time / 10;
    local limit = 21 * 10000 * 10000;
    return hp > limit and limit or hp;
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