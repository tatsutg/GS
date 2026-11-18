local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神具ジオ=ザグナス", version=1.3, id=2035901});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK5 = 50},
        { ATTACK1 = 50,ATTACK2 = 50}
    },
    HUMMER = {
        { ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 9
}

---
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 6
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 6
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 6
    },
    POIZON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 7
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}


--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;


class.RAGE_HP = 0.8;
class.RAGE_ATTACK_INDEX = 3;
class.GRENADE_RECAST = 10;


class.SUMMON_ENEMY_ID = 48924;
class.SUMMON_DELAY = 20;


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 50103,
        BUFF_ID = 22,
        VALUE = 200,
        DURATION = 99999,
        ICON = 11,
        FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end ---オーラ
    }
    self.BUFF_REMOVER = {
        ID = 50103,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 0.1,
        ICON = 79
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性",
            COLOR = Color.yellow
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "状態異常の時、被ダメージアップ",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "ゾルダス：クリティカル・魔法耐性",
            COLOR = Color.red
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "オルゲス：クリティカル・物理耐性",
            COLOR = Color.green
        })
    }
    self.GRAB_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.GRAB_MESSAGE1 or "HPが高い者をホールド"})
    }
    self.HUMMER_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HUMMER_MESSAGE1 or "怒り状態：一定のクリティカルダメージで解除",
            COLOR = Color.red
        })
    }
    self.HUMMER_LOST_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HUMMER_LOST_MESSAGE1 or "怒り状態解除！",
            COLOR = Color.red
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(5.8);---アタックディレイ
    event.unit:addSP(20)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true
    ---つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    ---投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    ---武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();
    --------------------
    self.subBar =  BattleControl:get():createSubBar();
    self.WEAPON_HP = event.unit:getCalcHPMAX() * 0.17
    --self.WEAPON_HP = 500
    self.WEAPON_DAMAGE = 0
    self.subBar:setWidth(200); --バーの全体の長さを指定
    self.subBar:setHeight(13);--バーの幅を指定
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);
    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    self.friendFLG = 3
    self.stunFLG = -1

    self.ragePoint = 0
    self.TIME_LIMIT = 240
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png",self.TIME_LIMIT ,30, 620 , -100 ,0.8);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(2,1)---ヒットストップ無効or時止め無効
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    if self.state == self.WEAPON_STATES.HUMMER then
        --event.unit:setReduceHitStop(2,0.8);--ヒットストップ無効Lv2　9.5割軽減
        --self:weaponCheck(event.unit);
        self:subBarControll(event.unit,self.WEAPON_DAMAGE);
    end
    self:grenadeCheck(event.deltaTime);
    self:countDown(event.deltaTime)
    self:findFriend()
    self:stunCheck(event.deltaTime)
    return 1
end

function class:checkTarget(unit)
    local index = 0
    local hp = 0
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if hp < localUnit:getHP() then
                index = i
                hp = localUnit:getHP()
            end
        end
    end
    return index
end

function class:stunCheck(deltaTime)
    if self.stunFLG > 0 then
        self.stunFLG = self.stunFLG - deltaTime
        if self.stunFLG <= 0 then
            self:execAddBuff(self.gameUnit,self.BUFF_REMOVER)
            self.stunFLG = -1
        end
    end
end

function class:countDown(deltaTime)
    self.TIME_LIMIT = self.TIME_LIMIT - deltaTime
    if self.TIME_LIMIT < -5 then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setHP(0)
            end
        end
    end
end

function class:findFriend()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    local count = 0
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + 1
        end
    end
    if count < self.friendFLG and self.friendFLG > 1 then
        self.friendFLG = self.friendFLG - 1
        self.ragePoint = self.ragePoint + 1
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    --if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.fromHost = false;
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
    self.gameUnit:setInvincibleTime(0)
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    --------------------------------------------------------------------------------------
    if self.addSpSkipFLG then
        if self.ragePoint > 0 and self.state ~= self.WEAPON_STATES.HUMMER then
            attackIndex = 3
            self.ragePoint = self.ragePoint - 1
            self:getRage(self.gameUnit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0)
        end
    end

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end
---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = self:checkTarget(event.unit)
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.skillCheckFlg = false;
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 2
    elseif self.isFury then
        skillIndex = 3
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local critical = event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        if self.state == self.WEAPON_STATES.HUMMER then
            self:weaponCheck(event.unit,event.value);
        end
    end
    if not self:findBadCondition(event.unit) then
        event.value = event.value * 0.2
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end


function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

function class:findBadCondition(unit)
    local cnt = 0;
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:allDead()
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:allDead()
    return 1
end

function class:allDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
        end
    end
end

--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    self.WEAPON_DAMAGE = 0
    self.spValue = 30;---addSPの量
    unit:setAttackDelay(3.5);
    self:execAddBuff(unit,self.BUFF_LIST)
    self:showMessage(self.HUMMER_MESSAGE_LIST)

    unit:setSetupAnimationName("setUpWeapon");
    self:initAttackWeight({HUMMER = 100})
end

function class:weaponCheck(unit,damage)
    self.WEAPON_DAMAGE = self.WEAPON_DAMAGE + damage
    if self.WEAPON_DAMAGE >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    self:initAttackWeight({DEFAULT = 100})
    self.spValue = 30;---addSPの量
    unit:setAttackDelay(5.8);
    self:showMessage(self.HUMMER_LOST_MESSAGE_LIST)
    self.stunFLG = 1.5
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
        self:showMessage(self.GRAB_MESSAGE_LIST)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
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
    hit:setActiveSkill(8);

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
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        else
            self:takeOtherAnimation(self.gameUnit,rand);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
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
--マルチ同期/
----------

function class:receive5(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:weaponBreak(self.gameUnit);
    return 1;
end

function class:receive7(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    self:showMessage(self.GRAB_MESSAGE_LIST)
    return 1;
end

function class:receive8(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive9(args)
    if args.arg == 0 then
        self:takePoizonGrenadeAnimation(self.gameUnit);
    else
        self:takeOtherAnimation(self.gameUnit);
    end
    return 1;
end

function class:takeDamage(event)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1;
end

--===============================================================================================================================================

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3

    local action = "use" .. receiveNumber

    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end
---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end



function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

class:publish();

return class;