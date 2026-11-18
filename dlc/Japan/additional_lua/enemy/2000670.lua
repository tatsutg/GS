local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2000670});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 1,
    SKILL1 = 4,
    SKILL3 = 5,
    SKILL2 = 8
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 200675,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    -- {
    --     ID = 200676,
    --     EFID = 28,         --スピード
    --     VALUE = 30,        --効果量
    --     DURATION = 9999999,
    --     ICON = 7
    -- },
    {
        ID = 200677,
        EFID = 27,         --ブレイク耐性
        VALUE = -30,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}


class.BUFF_VALUE = 30;
class.MIST_HP_DEFAULT = 45000;
class.FIX_DAMAGE_RATE = 0.6;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isMist = false;
    self.lastMistFlag = false;
    self.mistOrbit = nil;
    self.mistTimer = 0;
    self.forceSkillIndex = 0;
    self.mistHP = self.MIST_HP_DEFAULT;
    self.subBar = self:createSubBar(event.unit);
    self.damageCounter = 0;
    self.isLast = false;
    self.excution = false;
    self.mistStart = false;
    self.isRoot = false;
    self.hashiraCount = 0;
    event.unit:setSkillInvocationWeight(0);

    self.HP_TRIGGERS = {
        [75] = "takeMist",
        [50] = "takeMist",
        [30] = "getRage",
        [1] = "lastMist"
    }

    -- if table.maxn(self.TEXT) <= 0 then
    --     self.TEXT = {
    --         START_MESSAGE1 = "命中率UP",
    --         MIST_MESSAGE1 = "ダメージ蓄積開始",
    --         RAGE_MESSAGE1 = "行動速度UP",
    --         RAGE_MESSAGE2 = "ダメージUP",
    --         RAGE_MESSAGE3 = "ブレイク耐性UP",
    --         LAST_MESSAGE1 = "ゲージ破壊まで撃破不能"
    --     }
    -- end

    --開始時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1,
            COLOR = Color.red,
            DURATION = 5
        }
    }

    --霧展開のメッセージ
    self.MIST_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.MIST_MESSAGE1,
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    --霧展開のメッセージ
    self.LAST_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.LAST_MESSAGE1,
            COLOR = Color.red,
            DURATION = 10
        }
    }

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        -- [0] = {
        --     MESSAGE = self.TEXT.RAGE_MESSAGE1,
        --     COLOR = Color.red,
        --     DURATION = 5
        -- },
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2,
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3,
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    event.unit:setSPGainValue(0);
    return 1;
end

function class:takeDamageValue(event)
    
    if self.isRoot then
        local rootValue = math.sqrt(event.value);
        self.damageCounter = self.damageCounter + rootValue;
        self.mistHP = self.mistHP - rootValue;
        return rootValue;
    end
    local hpRate = ((event.unit:getHP() - event.value) * 100)/event.unit:getCalcHPMAX();
    if hpRate < 75 and self.HP_TRIGGERS[75] ~= nil then
        return event.unit:getHP() - event.unit:getCalcHPMAX() * 0.75;
    elseif hpRate < 50 and self.HP_TRIGGERS[50] ~= nil then
        return event.unit:getHP() - event.unit:getCalcHPMAX() * 0.5;
    elseif hpRate < 1 and self.mistHP >= 0 then
        return event.unit:getHP() - event.unit:getCalcHPMAX() * 0.01;
    end
    return event.value;
end

function class:startWave(event)
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:takeIdle(event)
    self:animationSwitcher(event.unit,"idle");
    return 1;
end


function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:mistCheck(event.unit,event.deltaTime);
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2（メリア以外のヒットストップを受けない）　減衰量１００％
    return 1;
end

function class:excuteAction(event)
    if self.excution then
        self.excution = false;
        self:mistTimeOver(event.unit);
    end
    if self.mistStart then
        self.mistStart = false;
        self:takeMist(event.unit);
    end
    return 1;
end

function class:dead(event)
    if self.mistHP <= 0 then
        return 1;
    end
    event.unit:setHP(1000);
    return 0;
end

function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "mistIn" then self:mistInCompleat(event.unit) end
    if event.spineEvent == "death" then self:death(event.unit) end
    if event.spineEvent == "finalExcution" then self:death(event.unit) end
    if event.spineEvent == "skull" then self:endOfHell(event.unit) end
    return 1;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////


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
    self:animationSwitcher(event.unit,"attack"..event.index);
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end
--===================================================================================================================

--===================================================================================================================
--スキル分岐//
--//////////

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
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
    self:animationSwitcher(event.unit,"skill"..event.index);
    event.unit:setBurstState(kBurstState_active);
    return 1
end

function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end
--===================================================================================================================
function class:animationSwitcher(unit,animstr)
    if not self.isMist and animstr ~= "skill3" and animstr ~= "attack3" then
        unit:setNextAnimationName("zcloneN"..animstr);
    end
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
            if self.hpMarkers[i] ~= nil then
                self.gameUnit:removeHpMarker(self.hpMarkers[i])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
    if trigger == "takeMist" and self.mistHP > 0 then
        self.mistStart = true;
        self.isRoot = true;
        self:showMessages(unit,self.MIST_MESSAGES);
    end

    if trigger == "lastMist" and self.mistHP > 0 then
        self.isLast = true;
        self.mistStart = true;
        self.isRoot = true;
        self:showMessages(unit,self.LAST_MESSAGES);
    end
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
--霧関係
function class:takeMist(unit)
    self.isMist = true;
    unit:takeIdle();
    self.attackCheckFlg = true;
    unit:takeAttack(3);
    self.mistTimer = 0;
    self.mistOrbit = unit:addOrbitSystem("blackmist_in");
    self.damageCounter = 0;
end

function class:mistInCompleat()
    self.mistOrbit:takeAnimation(0,"blackmist",true);
end

function class:mistCheck(unit,delta)
    if not self.isMist then
        return;
    end
    self.mistTimer = self.mistTimer + delta;
    if self.mistTimer >= 15 or self.mistHP <= 0 then
        self.excution = true;
    end
    self:subBarControll(unit);
end

function class:mistTimeOver(unit)
    if not self.isLast then
        self.isRoot = false;
        self.isMist = false;
        self.mistOrbit:takeAnimation(0,"blackmist_out",false);
        self.mistOrbit = nil;
        self.forceSkillIndex = 3;
    else
        if self.mistHP > 0 then
            self.mistTimer = 0;
        else
            self.isRoot = false;
            self.isMist = false;
            self.mistOrbit:takeAnimation(0,"blackmist_out",false);
            self.mistOrbit = nil;
            unit:setHP(0);
        end
        self.forceSkillIndex = 2;
    end
    
    unit:takeIdle();
    unit:addSP(unit:getNeedSP());
    
    unit:setInvincibleTime(30);
    self:subBarControll(unit);

    for i = 0,4 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then   
            uni:getTeamUnitCondition():addCondition(-12,89,100,8,0);
        end
    end
end


function class:death(unit)
    for i = 0,4 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            if self.isLast then
                self:deadOrAlive(unit,uni);
            else
                self:takeFixDamage(unit,uni);
            end
        end
    end
    unit:setInvincibleTime(0.1);
    self.damageCounter = 0;
end

function class:endOfHell(unit)
    
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill6001","attack1");
    self.hashiraCount = self.hashiraCount + 1;
    local num = self.hashiraCount%4+1;
    if num == 1 then
        orbit:setPositionX(200);
        orbit:setPositionY(0);
        orbit:setZOrder(unit:getZOrder() -400);
    elseif num == 2 then
        orbit:setPositionX(400);
        orbit:setPositionY(-100);
        orbit:setZOrder(unit:getZOrder() -400);
    elseif num == 3 then
        orbit:setPositionX(-200);
        orbit:setPositionY(100);
        orbit:setZOrder(unit:getZOrder() -400);
    else
        orbit:setPositionX(-400);
        orbit:setPositionY(-150);
        orbit:setZOrder(unit:getZOrder() +400);
    end
end

function class:takeFixDamage(unit,target)
    target:setHP(target:getHP()-self.damageCounter * self.FIX_DAMAGE_RATE);
    target:takeDamagePopup(unit,self.damageCounter * self.FIX_DAMAGE_RATE);
    -- 【MEGA_D-9756】メッセージログで、この技の行に画面に出した数字を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
    if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
        megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, target, self.damageCounter * self.FIX_DAMAGE_RATE)
    end
end

function class:deadOrAlive(unit,target)
    if self.mistHP > 0 then
        target:setHP(0);
        target:takeDamagePopup(unit,9999999);
    else
        local targetHP = target:getHP()/2;
        target:setHP(targetHP);
        target:takeDamagePopup(unit,targetHP);
        -- 【MEGA_D-9756】メッセージログで、この技の行に画面に出した数字を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
        if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
            megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, target, targetHP)
        end
    end
end

function class:createSubBar()
    local bar = BattleControl:get():createSubBar();

    bar:setWidth(350); --バーの全体の長さを指定
    bar:setHeight(17);
    bar:setPercent(0); --バーの残量を0%に指定
    bar:setVisible(false);
    bar:setPositionX(-210);
    bar:setPositionY(150);

    return bar;
end


function class:subBarControll(unit)
    
    if self.subBar == nil then
        return;
    end

    if not self.isMist then
        self.subBar:setVisible(false);
        return;
    end

    if self.mistHP > 0 then
        self.subBar:setVisible(true);
        self.subBar:setPercent(100 * self.mistHP/self.MIST_HP_DEFAULT);
    else
        self.subBar:setVisible(false);
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