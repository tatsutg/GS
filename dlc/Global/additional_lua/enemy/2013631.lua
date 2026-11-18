local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="金巨人", version=1.3, id=2013631});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 30,
    ATTACK2 = 30
}

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS_RAGE = {
    ATTACK1 = 10,
    ATTACK2 = 10,
    ATTACK5 = 40
}

class.ATTACK_RAGE = {
    ATTACK4 = 100;
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 6
}

class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 7
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 7
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 7
    },
    POIZON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 28,         --加速
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}

class.RAGE_BUFF_ARGS2 = {
    {
        ID = 400752,
        EFID = 0,         --加速
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}


--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;


class.RAGE_HP = -1;--今回は怒り無し
class.RAGE_ATTACK_INDEX = 3;
class.GRENADE_RECAST = 10;

class.WEAPON_HP = 100000;

class.SUMMON_ENEMY_ID = 48924;
class.SUMMON_DELAY = 20;


--===============================================================================================================================================
--デフォルトのイベント/
------------------
function class:start(event)

    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    self.gameUnit = event.unit;
    self.fromHost = false;
    
    --つかみ関連の変数たち

    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;

    --投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;

    --武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();

    --召喚用タイマー
    self.summonTimer = 0;


    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); --バーの全体の長さを指定
    self.subBar:setHeight(13);--バーの幅を指定
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);

    self.isGenosideMode = false;
    self.forceAttackIndex = 0;


    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    event.unit:setSPGainValue(0);

    self.HP_TRIGGERS = {

    }


    --怒り時のメッセージ
    -- self.SPEED_UP_MESSAGES = {
    --     [0] = {
    --         MESSAGE = self.TEXT.SPEED_UP_MESSAGE1 or "行動速度アップ",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.RAGE_MESSAGES1 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.RAGE_MESSAGE1 or "オマエ、コロス！",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.RAGE_MESSAGES2 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.RAGE_MESSAGE2 or "奥義ゲージ速度アップ",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }



    return 1;
end


function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = event.enemy:getIndex();
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value;
end


function class:run (event)
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
    return 1;
end

function class:update(event)
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　完全無効
    if self.state == self.WEAPON_STATES.HUMMER then
        event.unit:setReduceHitStop(2,0.8);--ヒットストップ無効Lv2　８割軽減
        self:weaponCheck(event.unit);
    end
    self:summon(event.unit,event.deltaTime);
    self:grenadeCheck(event.deltaTime);
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:attackBranch(unit)
    local waightsTable = self.ATTACK_WEIGHTS;

    if self.isGenosideMode then
        waightsTable = self.ATTACK_WEIGHTS_RAGE;
    end


    if self.state == self.WEAPON_STATES.HUMMER then
        waightsTable = self.ATTACK_RAGE;
    end


    local attackStr = summoner.Random.sampleWeighted(waightsTable);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if self.state == self.WEAPON_STATES.NONE and summoner.Utility.getUnitHealthRate(unit) < self.RAGE_HP and self:isHost() then
        attackIndex = self.RAGE_ATTACK_INDEX;
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end

    if self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,8,tonumber(attackIndex));
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
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1
end

function class:takeDamage(event)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1;
end

function class:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
    return 1;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1
end


--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:isHost() then
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
    if trigger == "speedUp" then
        self:speedUp(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,1);
    end

    if trigger == "genosideMode" then
        self:genosideMode(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,2);
    end

    if trigger == "lastSpart" then
        self:lastSpart(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,3);
    end
end

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
--怒り関係

function class:speedUp(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self:showMessages(unit,self.SPEED_UP_MESSAGES);
end

function class:genosideMode(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isGenosideMode = true;
    self:showMessages(unit,self.RAGE_MESSAGES1);
    self.forceAttackIndex = 5;
end

function class:lastSpart(unit)
    self.spValue = self.spValue * 2;
    self:addBuffs(unit,self.RAGE_BUFF_ARGS2);
    self:showMessages(unit,self.RAGE_MESSAGES2);
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


--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    unit:setAttackDelay(0);
    self.startBreakPoint = unit:getRecordBreakPoint();

end

function class:weaponCheck(unit)
    local weaponDamage = unit:getRecordBreakPoint() - self.startBreakPoint;
    self:subBarControll(unit,weaponDamage);
    if weaponDamage >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    unit:setAttackDelay(self.attackDelayDefault);
    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("2");
end

function class:subBarControll(unit,damage)
    local x = unit:getSkeleton():getBoneWorldPositionX("weapon2");
    local y = unit:getSkeleton():getBoneWorldPositionY("weapon2");
    self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    self.subBar:setPositionY(unit:getPositionY()+ y);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.WEAPON_HP - damage)/self.WEAPON_HP);
    if self.WEAPON_HP - damage <= 0 then
        self.subBar:setVisible(false);
    end
end

--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true; 
end



function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end
    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);

    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(9);
    
end

function class:glabFaild(unit)
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end
    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end
--===============================================================================================================================================
--投擲物関連のメソッド/
------------------

function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GRENADE_RECAST and self:isHost() then
        self.grenadeTimer = 0;
        local rand = LuaUtilities.rand(0,100);
        if rand < 50 then
            self:takePoizonGrenadeAnimation(self.gameUnit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        else
            self:takeOtherAnimation(self.gameUnit,rand);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        end
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POIZON);
end

function class:lunchOther(unit)
    --何を投げるかランダムで決定
    local rand = LuaUtilities.rand(0,100);
    local arg = {};


    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    else
        arg = self.ORBIT_ARGS.IRON;
    end

    self:lunch(unit,arg);
end

function class:lunch(unit,arg)
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:setActiveSkill(arg.activeSkill);
    
    local x = unit:getPositionX()
    local y = unit:getPositionY()
    local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
    local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
    bullet:setPosition(x+xb,y+yb);

    local counter = 0;
    local tgt = nil;
    while counter < 4 and tgt == nil do
        counter = counter + 1;
        tgt = self:getUnitByIndex(self.granedeTargetIndex%4);
        self.granedeTargetIndex = self.granedeTargetIndex + 1;
    end

    local targetx = 0;
    local targety = 0;
    

    if tgt ~= nil then
        targetx = tgt:getAnimationPositionX();
        targety = tgt:getAnimationPositionY();
    end


    LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
end

--===============================================================================================================================================
function class:summon(unit,deltaTime)
    -- self.summonTimer = self.summonTimer + deltaTime;
    -- if self.summonTimer < self.SUMMON_DELAY then
    --     return 1;
    -- else
    --     self.summonTimer = 0;
    -- end
    -- if not self:isHost() then
    --     return 1;
    -- end
    -- --0~1の場所が空席ならユニット召喚
    -- for i=0,1 do
    --     if unit:getTeam():getTeamUnit(i) == nil then
    --         unit:getTeam():addUnit(i,self.SUMMON_ENEMY_ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
    --     end
    -- end
    
    return 1;
end

--===============================================================================================================================================
--マルチ同期/
----------

function class:receive1(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive3(args)
    self:takePoizonGrenadeAnimation(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:takeOtherAnimation(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:weaponBreak(self.gameUnit);
    return 1;
end

function class:receive7(args)
    if args.arg == 1 then
        self:speedUp(self.gameUnit);
    elseif args.arg == 2 then
        self:genosideMode(self.gameUnit);
    else
        self:lastSpart(self.gameUnit);
    end
    return 1;
end

function class:receive8(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeAttackFromHost(unit,index)
    self.fromHost = true;
    unit:takeAttack(index);
end

--===============================================================================================================================================

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end



class:publish();

return class;
