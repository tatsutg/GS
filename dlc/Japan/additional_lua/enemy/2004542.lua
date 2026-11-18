local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹木マヴロスギア", version=1.9, id=2004542});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 },
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL5 = 5
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = -50015,
            BUFF_ID = 13, -- 攻撃力
            VALUE = 30,
            DURATION = 99999,
            ICON = 3
        },
        [2] = {
            ID = 500151,
            BUFF_ID = 89, -- スタン
            VALUE = 100,
            DURATION = 40,
            ICON = 0
        },
        [3] = {
            ID = 500152,
            BUFF_ID = 0, --フラグ
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [4] = {
            ID = -50015,
            BUFF_ID = 13, -- 攻撃力
            VALUE = -50,
            DURATION = 10,
            ICON = 4
        },
        [5] = {
            ID = -50015,
            BUFF_ID = 28, -- 攻撃速度
            VALUE = -20,
            DURATION = 10,
            ICON = 8
        },
        [6] = {
            ID = 500153,
            BUFF_ID = 29, -- スキルCT
            VALUE = -1000,
            DURATION = 40,
            ICON = 0
        },
        [7] = {
            ID = 500154,
            BUFF_ID = 30, -- 装備CT
            VALUE = -1000,
            DURATION = 40,
            ICON = 0
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性、人族キラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "状態異常のとき被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージの大きい者をターゲット"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのダメージアップ"})
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "攻撃力アップ"})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "奥義ゲージ上昇量アップ"})
    }
    self.GRAVITY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GRAVITY_MESSAGE1 or "が時空の狭間に消えた……"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
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

function class:hp80(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.hpFLG = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
    end
end

function class:hp60(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.hpFLG = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.BUFF_BOX_LIST[2].DURATION = 50
        self.BUFF_BOX_LIST[6].DURATION = 50
        self.BUFF_BOX_LIST[7].DURATION = 50
    end
end

function class:hp40(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.hpFLG = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.BUFF_BOX_LIST[2].DURATION = 60
        self.BUFF_BOX_LIST[6].DURATION = 60
        self.BUFF_BOX_LIST[7].DURATION = 60
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP40_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.hpFLG = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.BUFF_BOX_LIST[2].DURATION = 70
        self.BUFF_BOX_LIST[6].DURATION = 70
        self.BUFF_BOX_LIST[7].DURATION = 70
        self.spValue = 40
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 30;
    event.unit:setAttackDelay(3);
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

    ---火球用
    self.dejyonCounter = 0
    self.dejyonDuration = 15
    self.gravityPower = 200
    self.neckAngle = 321
    self.isFireEnd = false
    self.shotAngle = 0
    self.isFirst = false

    ---ターゲット選定用のテーブルなど
    self.damageTable = {}
    for i = 0,6 do self.damageTable[i] = 0 end
    self.targetUnitNum = 0

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)

    ---重力開始から終了までターゲット判定なし
    self.gravityFLG = false

    self.burstPoint = 0

    event.unit:takeAnimation(1,"setUpNormal",true);
    return 1
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
    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[4])
    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[5])
    self:itemCtReset(myTeamUnit)
    myTeamUnit:resetSkillCoolTime()
end

function class:getDeg(startx,starty,targetx,targety)
    return radToDeg(getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:getDistance(x1,y1,x2,y2)
    local squareResult = (x1 - x2) * (x1 - x2) + (y1 - y2)*(y1 - y2);
    return math.sqrt(squareResult);
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    event.unit:takeAnimation(1,"empty",false);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self.gameUnit:takeAnimation(1,"empty",false);
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
    event.unit:setReduceHitStop(100, 1);
    if not self.gravityFLG then
        if self:selectTarget() then
            self:HPTriggersCheck(event.unit)
        end
    end
    self:glabControll(event.unit,event.deltaTime)
    return 1
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
    -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
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



function class:gravityStart(unit)
    if not megast.Battle:getInstance():isHost() then
        return
    end
    self.gravityFLG = true
    local units = {}
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local myTeamUnit = myTeam:getTeamUnit(self.targetUnitNum)
    local target = myTeamUnit
    for i = 0,6 do self.damageTable[i] = 0 end

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

function class:selectTarget()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local maxDamage = 0
    local maxDamageUnit = -1
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID) == nil then
                if self.damageTable[i] > maxDamage then
                    maxDamage = self.damageTable[i]
                    maxDamageUnit = i
                end
            end
        end
    end
    if maxDamageUnit == -1 then
        self.targetUnitNum = 0
        return false
    else
        self.targetUnitNum = maxDamageUnit
        local myTeam = megast.Battle:getInstance():getTeam(true);
        local myTeamUnit = myTeam:getTeamUnit(self.targetUnitNum)
        self.gameUnit:setHateTarget(myTeamUnit)
        self.gameUnit:updateHateTarget();
        return true
    end
end

function class:setDownValue(target)
    if not self.isFirst then
        self.isFirst = true
        return (target:getCalcHPMAX() * 0.15) / 15
    else
        return (target:getCalcHPMAX() * 0.15) / 15
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
    self.BUFF_BOX_LIST[3].VALUE = self:setDownValue(target)
    self.isFirst = true;
    self:setGlabTarget(target)
    self.currentGlabPhase = self.glabPhase.gravity
    self.dejyonCounter = 0
    return 1
end

function class:gravityEnd(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local myTeamUnit = myTeam:getTeamUnit(self.targetUnitNum)
    local target = myTeamUnit
    self:addStanBuff(target)
    self.currentGlabPhase = self.glabPhase.hold
    local text = self.TEXT.GRAVITY_MESSAGE1 or "が時空の狭間に消えた……"
    summoner.Utility.messageByEnemy(self.glabTarget.unit:getUnitName()..text,
    7,Color.red)
    self.gameUnit:setInvincibleTime(0)
    self.gravityFLG = false
    self.gameUnit:addSP(self.burstPoint)
    self.burstPoint = 0
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

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end
    self.gravityFLG = false
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    --[[--下記コード使用で行動前に奥義ゲージが上がるユニットでも行動パターンを崩さず奥義を撃てる(必要に応じて改造)
    if self.gameUnit:getBurstPoint() ~= 80 then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    ]]--
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

    if event.index == 5 and self.hpFLG then
        self.hpFLG = false
        event.unit:setNextAnimationName("attack5")
        event.unit:setNextAnimationEffectName("1-attack5")
        self.gameUnit:setInvincibleTime(20)
    end

    if event.index == 2 then
        event.unit:setNextAnimationName("skill2fixed")
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self.gravityFLG = false
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9763】ボスの技の予告に、attackDamageValue の倍率（一番ダメージを与えた相手 targetUnitNum に ×2）を入れる（その 1 体だけ。技の途中で相手が替わるとずれる。表示専用。古いアプリには無いので確かめてから呼ぶ）
    if event.unit.announceSkillRate then local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.targetUnitNum); if u ~= nil then event.unit:announceSkillRate(2, u) end end
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.hpFLG then
        skillIndex = 5
    else
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
    local enemyUnit = self:getAncestorUnit(event.enemy)
    self.damageTable[enemyUnit:getIndex()] = self.damageTable[enemyUnit:getIndex()] + event.value
    self:selectTarget()
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end


function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    return unit:getHP() - border + 1
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder + 5 and event.unit:getHP() > stopBorder - 5 then
            return 0
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.glabTarget.unit ~= nil then
        self.currentGlabPhase = self.glabPhase.finish
    end
    return 1
end

----// attackDamageValue //-----------------------------------------------------------------------------
-- 条件 : 本体の攻撃Hit時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃対象  event.value / 与ダメージ量
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if event.enemy:getIndex() == self.targetUnitNum then
        event.value = event.value * 2
    end
    return event.value
end
----// attackDamageValue_OrbitSystem //-----------------------------------------------------------------------------
-- 条件 : オービットの攻撃Hit時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃対象  event.value / 与ダメージ量
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    if event.enemy:getIndex() == self.targetUnitNum then
        event.value = event.value * 2
    end
    return event.value
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
    for i,value in ipairs({89,91,96}) do
        local condition = unit:getTeamUnitCondition():findConditionWithType(value)
        if condition ~= nil then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
    end
end

class:publish();

return class;