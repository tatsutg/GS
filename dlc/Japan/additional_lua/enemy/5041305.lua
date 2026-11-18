local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="銀天景_氷精境_焔巨砦ゴルマーグ", version=1.3, id=5041305});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK5 = 50},
        { ATTACK1 = 50, ATTACK2 = 50 }
    },
    RAGE = {
        { ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    ATTACK8 = 8,
    SKILL1 = 9
}

class.cutInSkill = {
    --[3] = 1
}


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

class.WEAPON_HP = 100000;

class.SUMMON_ENEMY_ID = 48924;
class.SUMMON_DELAY = 20;


--------[[バフ]]--------
function class:setBuffBoxList()
    self.AURA_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        }
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射耐性",
            COLOR = Color.yellow
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "水属性以外のダメージを軽減",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼状態の敵へのダメージアップ",
            COLOR = Color.yellow
        })
    }
    self.GRAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.GRAD_MESSAGE1 or "HPが高い者をホールド",
            COLOR = Color.yellow
        })
    }
    self.RAGE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り状態：奥義上昇量アップ",
            COLOR = Color.red
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        }
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

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.HummerAttackIndex = 3;
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
    event.unit:setAttackDelay(7);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

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
    self.hpSkill = 0
    self.saveBP = 0


    --つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;

    --投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    self.myself = nil
    self.BeforetargetUnitIndex = 0
    self.bullets = {}
    self.bulletinfo = {
        new = function (_bullet,_targetUnit,_otherparam)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                jimen = 0,
                endAnimationName = "",
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1,
                yield = true
            }
        end
    }

    --武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();

    event.unit:addSubSkeleton("50003_leg",-30);
    event.unit:setSkin("1");

    self.forceAttackIndex = nil;
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --投擲
    self:grenadeCheck(event.deltaTime);
    --掴み投げ
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    --武器状態
    --if self.state == self.WEAPON_STATES.HUMMER then
    --    self:weaponCheck(event.unit);
    --end

    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "goblinAttack" then return self:goblinAttack(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    --if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
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
    self.isGlab = false;
    self.glabTargetIndex = nil;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
    self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.HummerAttackIndex ~= nil then
        attackIndex = self.HummerAttackIndex
        self.HummerAttackIndex = nil;
        self:getRage(unit)
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0)
    end

    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
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

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
    end

    if event.index == 2 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = self:checkTarget()
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value;
end

function class:checkTarget()
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---水属性判定
    local enemyElementType = event.enemy:getElementType()
    if enemyElementType ~= 2 then  --kElementType_Aqua
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
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if not self.isRage then
        event.unit:setNextAnimationName("idle")
    else
        event.unit:setNextAnimationName("idle2")
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
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



--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    self.isRage = true;
    unit:setSetupAnimationName("setUpWeapon");
    self:showMessage(self.RAGE_MESSAGE_LIST)
    self:initAttackWeight({RAGE = 100})
    self.spValue = 30;---addSPの量
    unit:setAttackDelay(5);---アタックディレイ
    self:execAddBuff(unit,self.AURA_BUFF_LIST[1])

    --unit:setAttackDelay(0);
    --self.startBreakPoint = unit:getRecordBreakPoint();
end
--[[
function class:weaponCheck(unit)
    local weaponDamage = unit:getRecordBreakPoint() - self.startBreakPoint;
    --self:subBarControll(unit,weaponDamage);
    if weaponDamage >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    unit:setAttackDelay(self.attackDelayDefault);
    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    --unit:setReduceHitStop(0,0);--ヒットストップ無効解除
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
--]]
--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true;
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end

    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        self:showMessage(self.GRAD_MESSAGE_LIST)
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end
end

function class:checkTarget()
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
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        else
            self:takeOtherAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        end
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POIZON);
end

function class:goblinAttack(unit)
    if unit:getHP() <= 0 then
        return 0;
    end

    unit:setTargetUnit(megast.Battle:getInstance():getTeam(true):getTeamUnit(self.BeforetargetUnitIndex));
    if unit:getTargetUnit() ~= nil then
        local rand = LuaUtilities.rand(0,100);
        local animationStr = "";
        local endAnimationName = "";
        local vanishAnimationName = "";
        local speed = 10;
        local activeSkillNum = 0;
        if rand < 25 then
            activeSkillNum = 6;
            animationStr = "goblin_ax";
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_axEnd";
        elseif rand < 50 then
            activeSkillNum = 6;
            animationStr = "goblin_bone"
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_bone_bound";
        elseif rand < 75 then
            activeSkillNum = 6;
            animationStr = "goblin_iron-ball"
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_iron-ballEnd";
        else
            activeSkillNum = 7;
            animationStr = "goblin_poison"
            endAnimationName = "goblin_poison_dusty";
            vanishAnimationName = "goblin_poison_dusty";
        end

        local bullet = unit:addOrbitSystem(animationStr,1);
        bullet:takeAnimation(0,animationStr,true);
        bullet:setHitCountMax(1);
        bullet:setEndAnimationName(endAnimationName);
        bullet:getTeamUnitCondition():addCondition(-12,35,0,25,0);
        bullet:setActiveSkill(activeSkillNum);
        local x = unit:getPositionX()
        local y = unit:getPositionY()
        local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
        local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
        bullet:setPosition(x+xb,y+yb);

        local targetx = unit:getTargetUnit():getPositionX();
        local targety = unit:getTargetUnit():getPositionY();

        LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
        local t = self.bulletinfo.new(bullet,unit:getTargetUnit():getIndex(),0);
        t.jimen = unit:getTargetUnit():getPositionY() + 10;
        t.endAnimationName = vanishAnimationName;
        t.speedkeisuu = speed;
        table.insert(self.bullets,t);
    end
    return 1
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


--===================================================================================================================
--怒り関係
function class:speedUp(unit)
    --self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    --self:showMessages(unit,self.SPEED_UP_MESSAGES);
end

function class:genosideMode(unit)
    --self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    --self.forceAttackIndex = 5;
    --self.isGenosideMode = true;
    --self:showMessages(self.RAGE_MESSAGE_LIST);
    --self:initAttackWeight({RAGE = 100})
    --self.spValue = 30;---addSPの量
    --unit:setAttackDelay(5);---アタックディレイ
    --self:execAddBuff(unit,self.AURA_BUFF_LIST[1])
end

function class:lastSpart(unit)
    --self.spValue = self.spValue * 2;
    --self:addBuffs(unit,self.RAGE_BUFF_ARGS2);
    --self:showMessages(unit,self.RAGE_MESSAGES2);
end


--===============================================================================================================================================
--マルチ同期/
----------

function class:receive7(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    return 1;
end

function class:receive8(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive9(args)
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



class:publish();

return class;