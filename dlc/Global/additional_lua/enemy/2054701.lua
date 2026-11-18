local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神具／マヴロスギア", version=1.3, id=2054701});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK2=50},
        {ATTACK1=50, ATTACK4=50},
        {ATTACK2=50, ATTACK3=50},
        {ATTACK3=50, ATTACK4=50},
        {ATTACK1=50, ATTACK3=50}
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        {SKILL1=50},
        {SKILL2=50}
    }
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

class.cutInSkill = {
    --[2] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20547011,
            BUFF_ID = 13,---攻撃力ダウン
            VALUE = -50,
            DURATION = 20,
            ICON = 4
        },
        [2] = {
            ID = 500151,
            BUFF_ID = 89, -- スタン
            VALUE = 100,
            DURATION = 10,
            ICON = 0
        },
        [3] = {
            ID = 500152,
            BUFF_ID = 0, --フラグ
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [6] = {
            ID = 500153,
            BUFF_ID = 29, -- スキルCT
            VALUE = -1000,
            DURATION = 10,
            ICON = 0
        },
        [7] = {
            ID = 500154,
            BUFF_ID = 30, -- 装備CT
            VALUE = -1000,
            DURATION = 10,
            ICON = 0
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 14050,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 100,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 14050,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 0.1,
        ICON = 0
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性・庇うキラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "暗闇状態の敵からのダメージを軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "HPが高いユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット・クリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ドゥーラ：魔法耐性", COLOR = Color.green})
    }
    self.GRAVITY_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.GRAVITY_MESSAGE1 or "%sが時空の狭間に消えた……", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.GRAVITY_MESSAGE2 or "%s族からのダメージ軽減", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ドゥーラ：魔法耐性", COLOR = Color.green})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        --[[
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
        ]]--
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
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
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(13);---アタックディレイ
    --event.unit:addSP(20)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

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

    self.attack5FLG = false

    --自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}

    ---重力用の変数いろいろ
    self.glabTarget = {
        unit = nil,
        x = 0,
        y = 0
    }
    self.currentGlabPhase = 0
    self.glabPhase = {
        none = 0,
        gravity = 1,
        hold = 2,
        fade = 3,
        finish = 4
    }
    self.glabPhaseContents = {
        [2] = {
            useAction = function(unit,deltaTime) self:useHold(unit) end
        },
        [4] = {
            useAction = function(unit,deltaTime) self:useFinish(unit) end
        }
    }
    self.gravityFLG = false

    ---火球用
    self.dejyonCounter = 0
    self.dejyonDuration = 15
    self.gravityPower = 200
    self.neckAngle = 321
    self.isFireEnd = false
    self.shotAngle = 0
    self.isFirst = false

    self.saveTarget = nil

    self.RACE_LIST = {
        [1] = self.TEXT.RACE1 or "人",
        [2] = self.TEXT.RACE2 or "獣",
        [3] = self.TEXT.RACE3 or "精霊",
        [4] = self.TEXT.RACE4 or "巨人",
        [5] = self.TEXT.RACE5 or "機",
        [6] = self.TEXT.RACE6 or "竜",
        [7] = self.TEXT.RACE7 or "神",
        [8] = self.TEXT.RACE8 or "魔"
    }
    self.targetRace = {}
    for i = 1,8 do
        self.targetRace[i] = false
    end

    self.clearTime = 300
    ---右上タイマー表示
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.clearTime ,30, 620 , -100 ,0.8);

    event.unit:takeAnimation(1,"setUpNormal",true);
    return 1
end

----// startWave //-----------------------------------------------------------------------------
-- 条件 : wave開始時。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:startWave(event)
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if BattleControl:get():getTime() >= self.clearTime then
        self:allDead()
    end
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:glabControll(event.unit,event.deltaTime)
    return 1
end

function class:allDead()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
            myTeamUnit:getTeam():deadUnit(myTeamUnit:getIndex());
        end
    end
end

function class:glabControll(unit,deltaTime)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID) ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID) ~= nil then
                    self.glabPhaseContents[2].useAction(myTeamUnit,deltaTime)
                else
                    print("闇ドラゴン　除外時間終了");
                    self.currentGlabPhase = self.glabPhase.finish;
                    self.glabPhaseContents[4].useAction(myTeamUnit,deltaTime)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    -- if event.spineEvent == "targetLock" then self:targetLock(unit) end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    if event.spineEvent == "setFire" then self:setFire(event.unit) end
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "startFire" then self:startFire(event.unit) end
    if event.spineEvent == "gravityStart" then self:gravityStart(event.unit) end
    if event.spineEvent == "gravityEnd" then self:gravityEnd(event.unit) end
    if event.spineEvent == "hideUnit" then self:hideUnit(event.unit) end
    return 1
end

function class:fire(unit)
    local shot = unit:addOrbitSystem("fireball",1)
    shot:setActiveSkill(1);
    shot:setHitCountMax(1);
    shot:setEndAnimationName("explosion")
    -- shot:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
    shot:setPosition(x+xb,y+yb);
    shot:setRotation(-self.neckAngle);
    self.shotAngle = self.neckAngle;
    shot:setZOrder(unit:getZOrder() -1);
    self.isFireEnd = true;
end

function class:setFire(unit)
    if not self.isRage then return end

    local shot = unit:addOrbitSystem("firePiller",2)
    shot:setHitCountMax(999);
    shot:setEndAnimationName("fireEnd");
    -- shot:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = 0;
    local yb = 0;

    local rand = math.random(5);

    if rand == 1 then
        xb = 300;
    elseif rand == 2 then
        xb = 350;
        yb = -100;
    elseif rand == 3 then
        xb = 400;
        yb = 50;
    elseif rand == 4 then
        xb = 500;
    elseif rand == 5 then
        xb = 600;
        yb = 100;
    end

    shot:setPosition(x+xb,y+yb);
    shot:setAutoZOrder(true);
    shot:setZOderOffset(-5000);
end

function class:startFire(unit)
    local headangle = unit:getSkeleton():getBoneRotation("head");

    print("start fire");
end

function class:useHold(myTeamUnit)
    myTeamUnit:setPosition(myTeamUnit:getPositionX(),-1000)
end

function class:useFinish(myTeamUnit)
    local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(500152);
    if buff ~= nil then
        myTeamUnit:getTeamUnitCondition():removeCondition(buff);
    end

    myTeamUnit:getSkeleton():setPosition(0,1000);--解放するときは上空から落とす
    myTeamUnit:setOpacity(255);
    myTeamUnit:resumeUnit();
    if myTeamUnit:getBurstPoint() < 0 then
        myTeamUnit:setBurstPoint(0);
    end
    self.currentGlabPhase = self.glabPhase.none;
    self.glabTarget.unit = nil;
    self:itemCtReset(myTeamUnit)
    myTeamUnit:resetSkillCoolTime()
    --self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
end

function class:gravityStart(unit)
    if not megast.Battle:getInstance():isHost() then
        return
    end
    self.gravityFLG = true
    local units = {}
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = self:checkTargetUnit()
    self.saveTarget = target

    --吸引対象に設定
    if target ~= nil then
        self:setGlabTarget(target)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex());
        target:resumeUnit();
        self:addStanBuff(target);
        self.currentGlabPhase = self.glabPhase.gravity;
        self.dejyonCounter = 0;
    end
end

function class:addStanBuff(target)
    self:execAddBuff(target,self.BUFF_BOX_LIST[2])
    self:execAddBuff(target,self.BUFF_BOX_LIST[3])
    self:execAddBuff(target,self.BUFF_BOX_LIST[6])
    self:execAddBuff(target,self.BUFF_BOX_LIST[7])
    target:resetSkillCoolTime();
    self:itemCtReset(target)
end

function class:itemCtReset(target)
    for n = 0,2 do
        local item = target:getItemSkill(n)
        if item ~= nil then
            item:resetCooltime()
        end
    end
end

function class:setGlabTarget(target)
    self.glabTarget.unit = target
    self.glabTarget.x = target:getPositionX();
    self.glabTarget.y = target:getPositionY();
end

function class:receive5(args)
    local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg)
    self.saveTarget = target
    self.isFirst = true;
    self:setGlabTarget(target)
    target:resumeUnit();
    self:addStanBuff(target);
    self.currentGlabPhase = self.glabPhase.gravity
    self.dejyonCounter = 0
    return 1
end

function class:gravityEnd(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = self.saveTarget
    --self:addStanBuff(target)
    self.currentGlabPhase = self.glabPhase.hold
    if target ~= nil then
        self.targetRace[target:getRaceType()] = true
        self:showFormatMessage(self.GRAVITY_MESSAGE_LIST[1],target:getUnitName())
        self:showFormatMessage(self.GRAVITY_MESSAGE_LIST[2],self.RACE_LIST[target:getRaceType()])
        local index = target:getIndex() + (target:getBaseID3() * 10)
        self.targetUnitList[index].dps = 0
    end
    self.gameUnit:setInvincibleTime(0)
    self.gravityFLG = false
end

function class:hideUnit(unit)
    self.currentGlabPhase = self.glabPhase.fade
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

    if event.index == 5 then
        if self:MultipleSummon(event.unit,2054702,2) then
            self:showMessage(self.SUMMON_MESSAGE_LIST)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end
    ---重力攻撃中は無敵
    if event.index == 5 then
        self.gameUnit:setInvincibleTime(10)
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.attack5FLG then
        attackIndex = 5
        self.attack5FLG = false
    else
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end

function class:summon(unit,unitID)
    local flg = false
    if megast.Battle:getInstance():isHost() then
        for i = 0, 4 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                flg = true
                break
            end
        end
    end
    return flg
end

function class:MultipleSummon(unit,unitID,Num)
    local flg = false
    for i = 1,Num do
        flg = self:summon(unit,unitID)
    end
    return flg
end

---------------------------------------------------------------------------------
-- receive8
---------------------------------------------------------------------------------
function class:receive8(args)
    self:showMessage(self.SUMMON_MESSAGE_LIST)
    return 1
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

    if event.index == 2 then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:weakenBadCondition(myTeamUnit,56,-20)
            end
        end
    end
    
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self.attack5FLG = true
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

---状態異常耐性---
function class:weakenBadCondition(unit,buffID,value)
    local BUFF_LIST = {
        ID = 20547018,
        BUFF_ID = buffID,
        VALUE = value,
        DURATION = 99999,
        ICON = buffID + 16,
        MAX = 10
    }
    local BUFF_LIST2 = {
        ID = 20547019,
        BUFF_ID = buffID + 49,
        VALUE = value,
        DURATION = 99999,
        ICON = 0,
        MAX = 10
    }
    self:execAddBuff(unit,BUFF_LIST)
    self:execAddBuff(unit,BUFF_LIST2)
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---暗闇
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local cond = enemyUnit:getTeamUnitCondition():findConditionWithType(93);
    if cond ~= nil then
        event.value = event.value * 0.1
    end
    ---プレイヤーユニットのHP
    local x = enemyUnit:getHPPercent() * 100
    local rate = 0.5 * 2.5/math.pi * math.atan(0.12 * (x - 95)) + 0.78
    --summoner.Utility.messageByEnemy(rate)
    event.value = event.value * rate
    ---特定種族
    if self.targetRace[enemyUnit:getRaceType()] then
        event.value = event.value * 0.01
    end

    event.value = self:adjustHpFlg(event.unit,event.value)

    if event.enemy:getIndex() == 4 then return event.value end
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(self.TARGET_BUFF_LIST1.ID)
                end
            end
        end
    end
    ------
    return event.value
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
            else
                myTeamUnit:getTeamUnitCondition():removeConditionWithID(self.TARGET_BUFF_LIST1.ID)
            end
        end
    end
    return 1
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

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0
        elseif v.dps >= val then
            val = v.dps
            target = v.unit
        end
    end
    return target
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
    local enemyUnit = self:getAncestorUnit(event.enemy)
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
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    event.unit:takeAnimation(1,"empty",false);
    megast.Battle:getInstance():waveEnd(true);
    return 1
end

function class:receive4(args)
    self.gameUnit:takeAnimation(1,"empty",false);
    megast.Battle:getInstance():waveEnd(true);
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

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
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
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,index)
        return;
    end

    self.TRIGGERS[index].action(action)
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
---------------------------------------------------------------------------------
-- receive7(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive7(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > 10 then
                count = 10
            end
        end
    end
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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