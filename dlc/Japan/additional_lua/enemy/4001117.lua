--@additionalEnemy,4001116
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="樹ドラ", version=1.3, id=4001117});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 100,
    ATTACK2 = 100,
    ATTACK3 = 100,
    ATTACK4 = 100
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
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

class.ATTACK_ANIMATIONS = {
    [1] = {set = function(unit) unit:takeAnimation(0,"zcloneNattack1",false) end},
    [2] = {set = function(unit) unit:setNextAnimationName("zcloneNattack2") end},
    [3] = {set = function(unit) unit:setNextAnimationName("zcloneNattack3") end},
    [4] = {set = function(unit) unit:setNextAnimationName("zcloneNattack4") end},
    [5] = {set = function(unit) unit:setNextAnimationName("zcloneNattack5") end}
}

class.SKILL_ANIMATIONS = {
    [1] = {set = function(unit) unit:setNextAnimationName("zcloneNskill1") end},
    [2] = {set = function(unit) unit:setNextAnimationName("zcloneNskill2") end}
}

class.DARK_COROC_ID = 4001116

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20157501,
            BUFF_ID = 22, -- クリティカル
            VALUE = 20,
            DURATION = 999999,
            ICON =11
        },
        [2] = {
            ID = 20157502,
            BUFF_ID = 22, -- クリティカル
            VALUE = 20,
            DURATION = 999999,
            ICON = 11
        },
        [3] = {
            ID = 20157503,
            BUFF_ID = 28, -- 行動速度
            VALUE = 20,
            DURATION = 999999,
            ICON = 7
        }
    }
    self.BUFF_BOX_LIST_DIVE = {
        [1] = {
            ID = 201575011,
            BUFF_ID = 24, -- ブレイク固定値
            VALUE = 20,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 201575012,
            BUFF_ID = 25, -- ブレイク割合
            VALUE = 10,
            DURATION = 999999,
            ICON = 9
        },
        [3] = {
            ID = 201575013,
            BUFF_ID = 109, -- 燃焼回避
            VALUE = -100,
            DURATION = 999999,
            ICON = 76
        }
    }
    self.BUFF_BOX_LIST_REGENERATION = {
        [1] = {
            ID = 201575021,
            BUFF_ID = 7, -- 自然回復
            VALUE = 300,
            DURATION = 999999,
            ICON = 35
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "魔法ダメージ・水属性ダメージ無効"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "燃焼中、被ダメージアップ"
        })
    }
    self.HP70_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "クリティカル率アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE2 or "HP自然回復量アップ"
        })
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル率アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "HP自然回復量アップ"
        })
    }
    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "行動速度アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE2 or "HP自然回復量アップ"
        })
    }

    self.SKILL_MESSAGE = self:setMessageInfo({
        MESSAGE = self.TEXT.SKILL_MESSAGE or "不滅の竜に力が集まる……",
        COLOR = Color.red
    })
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            trigger.hpMarker = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:hp70(status)
    if status == "use3" then
        self.BUFF_BOX_LIST_REGENERATION[1].VALUE = 500
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST_REGENERATION[1])
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.BUFF_BOX_LIST_REGENERATION[1].VALUE = 700
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST_REGENERATION[1])
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.BUFF_BOX_LIST_REGENERATION[1].VALUE = 3000
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[3])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST_REGENERATION[1])
        self:showMessage(self.HP30_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hitStop = 1
    self.isRage = false
    self.isFury = false
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()
    self:showMessage(self.START_MESSAGE_LIST)

    self.isLockOn = false
    self.isFireEnd = false
    self.shotAngle = 0
    self.neckAngle = 0
    self.neckAngleDefault = 321
    self.attackdelayOriginal = event.unit:getAttackDelay()
    self.rageTimer = 0
    self.attackCount = 4
    self.barnBreakDamageParSecond = 200
    self.rageHealBreakValue = 600
    event.unit:setSetupAnimationName("setUpNormal");
    event.unit:takeAnimation(1,"empty",false);
    event.unit:setZOderOffset(-100)
    self:execAddBuff(event.unit, self.BUFF_BOX_LIST_REGENERATION[1])
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    if event.spineEvent == "setFire" then self:setFire(event.unit) end
    --if event.spineEvent == "explosion" then self:explosion(event.unit) end
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "startFire" then self:startFire(event.unit) end
    if event.spineEvent == "addBuff" then self:addBuffRun(event.unit) end
    return 1
end

----: run :---->>>>
function class:targetLock()
    self.isLockOn = true
    self.neckAngle = 321
end

----: run :---->>>>
function class:fire(unit)
    local shot = unit:addOrbitSystem("fireball",1)
    shot:setActiveSkill(1);
    shot:setHitCountMax(1);
    shot:setEndAnimationName("explosion")

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

----: run :---->>>>
function class:setFire(unit)
    if not self.isRage then return end

    local shot = unit:addOrbitSystem("firePiller",2)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = 0;
    local yb = 0;
    local rand = math.random(5);
    shot:setHitCountMax(999);
    shot:setEndAnimationName("fireEnd");

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

----: run :---->>>>
function class:addSP(unit)
    unit:addSP(self.spValue);
end

----: run :---->>>>
function class:startFire(unit)
    local headAngle = unit:getSkeleton():getBoneRotation("head");
    self.neckAngle = headAngle;
    self.neckAngleDefault = headAngle;
end

----: run :---->>>>
function class:addBuffRun(unit)
    --self.isRage = true;
    --self.rageTimer = 0
    --self:addBuff(unit,self.BUFF_BOX_LIST_DIVE)
    --self:addBuff(unit,self.BUFF_BOX_LIST_REGENERATION)
    --self:showMessage(self.MESSAGE_BOX_DIVE)
    self:summon(unit,self.DARK_COROC_ID,1)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(2,self.hitStop)
    self:HPTriggersCheck(event.unit)
    self:attack5ArmControl(event.unit)
    self:findBurn(event.unit,event.deltaTime)
    return 1
end

----: update :---->>>>
function class:attack5ArmControl(unit)
    if self.isLockOn then self:boneRotation(unit,"head") end
end

----: update :---->>>>
function class:findBurn(unit,deltaTime)
    local condValue = unit:getTeamUnitCondition():findConditionValue(97);

    if condValue ~= 0 then
        unit:setBreakPoint(unit:getBreakPoint() - self.barnBreakDamageParSecond * deltaTime);
    end
    self:checkRage(unit,condValue,deltaTime)
end

----: update/attack5ArmControl :---->>>>
function class:boneRotation(unit,boneName)
    if not self.isFireEnd then
        unit:getSkeleton():setBoneRotation(boneName,self:calcDeg(unit,boneName));
    else
        unit:getSkeleton():setBoneRotation(boneName,self:calcDegForEnd());
    end
    return 1;
end

----: update/attack5ArmControl :---->>>>
function class:calcDeg(unit,boneName)
    local target = unit:getTargetUnit();
    if target == nil then return 0 end

    local targetAngle = self:getTargetAngle(unit,boneName,target)
    local dir = self:getDir(targetAngle)
    self.neckAngle = self.neckAngle + dir;
    if self.neckAngle > 360 then self.neckAngle = self.neckAngle % 360 end
    if self.neckAngle < 0    then self.neckAngle = 360 - self.neckAngle end
    if self.neckAngle < 270 and  self.neckAngle > 180 then
        self.neckAngle = 270
    elseif self.neckAngle > 90 and self.neckAngle <= 180 then
        self.neckAngle = 90
    end

    return self.neckAngle
end

----: update/attack5ArmControl :---->>>>
function class:calcDegForEnd()
    local targetAngle = self.neckAngleDefault
    if targetAngle < 0 then
        targetAngle = 360 + targetAngle
    end

    local dir = self:getDir(targetAngle)

    self.neckAngle = self.neckAngle + dir;
    if self.neckAngle > 360 then self.neckAngle = self.neckAngle % 360  end
    if self.neckAngle < 0    then self.neckAngle = 360 - self.neckAngle  end

    print(dir);
    return self.neckAngle;
end

----: update/attack5ArmControl :---->>>>
function class:getTargetAngle(unit,boneName,target)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
    local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
    local tx = target:getPositionX();
    local ty = target:getPositionY();
    local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
    local targetAngle = self:getDeg(x+xb,y+yb,tx+txb,ty+tyb) + 18;
    if targetAngle < 0 then
        targetAngle = 360 + targetAngle;
    end
    return targetAngle
end

----: update/attack5ArmControl :---->>>>
function class:getDir(targetAngle)
    local dir = targetAngle - self.neckAngle

    if dir > 180 then dir = -(360 - dir) end
    if dir < -180 then dir = (360 + dir) end
    if dir ~= 0 then
        local maxdir = 1 * unitManagerDeltaTime/0.016666667;
        if dir > maxdir then
            dir = maxdir;
        elseif dir < -maxdir then
            dir = -maxdir;
        end
    end

    return dir
end

----: update/findBurn :---->>>>
function class:checkRage(unit,condValue,deltaTime)
    if not self.isRage then return end

    local buff_ =  unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST_REGENERATION[1].ID);
    if condValue == 0 then
        if buff_ == nil then
            self:showMessage(self.MESSAGE_BOX_REGENERATION_RESTART)
            self:addBuff(unit,self.BUFF_BOX_LIST_REGENERATION)
        end
        unit:setBreakPoint(unit:getBreakPoint() + self.rageHealBreakValue * deltaTime);
    else
        if buff_ ~= nil then
            self:showMessage(self.MESSAGE_BOX_REGENERATION_STOP)
            self:execRemoveCondition(unit,self.BUFF_BOX_LIST_REGENERATION[1].ID)
        end
    end

    if megast.Battle:getInstance():isHost() then
        self.rageTimer = self.rageTimer + deltaTime;
        if self.rageTimer > 60 then
            self:rageEnd(unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
        end
    end
end

function class:receive4(args)
    self:rageEnd(self.gameUnit);
    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self.isLockOn = false
    self.isFireEnd = false
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    for i = 0, 6 do
        local u = event.unit:getTeam():getTeamUnit(i)
        if u ~= nil and u ~= event.unit then
            u:setHP(0)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
    self:rageEnd(event.unit)
    return 1
end

----: takeBreake :---->>>>
function class:rageEnd(unit)
    if not self.isRage then return end

    self.isRage = false;
    self.rageTimer = 0;
    unit:setAttackDelay(self.attackdelayOriginal);
    unit:setSetupAnimationName("setUpNormal");
    unit:takeAnimation(1,"empty",false);

    self:removeBuff(unit,self.BUFF_BOX_LIST_DIVE)
    self:removeBuff(unit,self.BUFF_BOX_LIST_REGENERATION)
    self:showMessage(self.MESSAGE_BOX_DIVE_END)
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if not self.isRage then
        event.unit:setNextAnimationName("zcloneNidle");
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if not self.isRage then
        event.unit:setNextAnimationName("zcloneNback");
    end
    return 1
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
    self:attackActiveSkillSetter(event.unit,event.index);

    if not self.isRage then
        self.ATTACK_ANIMATIONS[event.index].set(event.unit)
    end
    
    if event.index == 5 then
        event.unit:setSetupAnimationName("setUpFire");
        event.unit:takeAnimation(1,"reaf",true);
        event.unit:setAttackDelay(self.attackdelayOriginal/2);
    end

    return 1
end

function class:attackReroll(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self.attackCount = self.attackCount + 1

    if self.attackCount > 3 then
        self.attackCount = 0
        attackIndex = 5
    end

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
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

    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);

    if event.index == 1 then
        self:summon(event.unit,self.DARK_COROC_ID,2)
    else
        self:summon(event.unit,self.DARK_COROC_ID,3)
    end

    if not self.isRage then
        self.SKILL_ANIMATIONS[event.index].set(event.unit)
    end

    self:execShowMessage(self.SKILL_MESSAGE)
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if summoner.Utility.getUnitHealthRate(unit) * 100 < 30 then
        skillIndex = 2
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
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

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true

    if self.TRIGGERS[index].hpMarker ~= nil then
        self.gameUnit:removeHpMarker(self.TRIGGERS[index].hpMarker)
    end

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].hpMarker ~= nil then
        self.gameUnit:removeHpMarker(self.TRIGGERS[args.arg].hpMarker)
    end
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
    for i,messageBox in ipairs(messageBoxList) do
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
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

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


function class:removeBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execRemoveCondition(unit,buffBox.ID)
    end
end

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end
end

--------------------------------------------------------------------------------
-- ユニット追加
--------------------------------------------------------------------------------
function class:summon(unit,unitID,count)
    local c = count
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil and c > 0 then
                c = c - 1
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            end
        end
    end
end



function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end


class:publish();

return class;