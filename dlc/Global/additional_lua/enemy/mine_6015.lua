local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山エルプネウマス絶", version=1.3, id="mine_6015"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50},
        { ATTACK5 = 50},
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50},
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50},
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50}
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
    SKILL1 = 6,
    SKILL2 = 7
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP50_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 7,
            VALUE = 0.6 + self.floor * 0.002,
            DURATION = 30,
            ICON = 35,
            SCRIPT = {
                SCRIPT_ID = 238,
                VALUE1 = 0
            }
        }
    }
    self.PARALYZE_BUFF_LIST = {
        [1] = {
            ID = 50171,
            BUFF_ID = 91,
            VALUE = 100,
            DURATION = 1 + self.floor * 0.1,
            ICON = 81
        }
    }
    self.POISON_UPWARD_BUFF_LIST = {
        [1] = {
            ID = 50172,
            BUFF_ID = 201,
            VALUE = self.floor * 15,
            DURATION = 99999,
            ICON = 301,
            SCRIPT = {
                SCRIPT_ID = 601,
                VALUE1 = 1,
                VALUE2 = 5
            }
        }
    }
    self.TIMEUP_BUFF_BOX_LIST = {
        [1] = {
            ID = 5000033,
            BUFF_ID = 17,      --ダメージ
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 5000036,
            BUFF_ID = 13,      --攻撃力
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 3
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "樹属性耐性"})
    }
    self.TIMEUP_BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TIME_UP_ID = 3
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp90(status) end,
            HP = 90,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [self.TIME_UP_ID] = {
            tag = "TIME_UP",
            action = function (status) self:timeUp(status) end,
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

function class:hp90(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.isRage = true
        self.gameUnit:addSP(100)
        self.HpFlgAddSp = 40
        --self:POISON_UPWARD()
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_LIST[1])
        self.gameUnit:setInvincibleTime(15)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.isRage = true
        self.gameUnit:addSP(100)
        self.HpFlgAddSp = 60
        --self:POISON_UPWARD()
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_LIST[1])
        self.gameUnit:setInvincibleTime(15)
    end
end

function class:POISON_UPWARD()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond201 = myTeamUnit:getTeamUnitCondition():findConditionWithType(201);
            if cond201 == nil then
                self:execAddBuff(myTeamUnit,self.POISON_UPWARD_BUFF_LIST[1])
            end
        end
    end
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
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
    self.afterSkillFLG = false;

    self.BreakDamageCount = 0

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self.floor = megast.Battle:getInstance():getCurrentMineFloor();
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.cutInFLG = false
    self.HpFlgAddSp = 0
    self.messageFLG = false
    self.attack6FLG = false
    self.attack2FLG = false
    self.skill3FLG = false
    self.telopSpan = 60
    self.showMessageTimer = 0
    self.attack6Damage = {}
    self.attack2Paralyze = {}
    self.firstAttack = true

    self.isLockOn = false
    self.isFireEnd = false
    self.shotAngle = 0
    self.neckAngle = 0
    self.neckAngleDefault = 321
    return 1
end

function class:startWave(event)
    event.unit:setAttackDelay(3.3)
    event.unit:addSP(60)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)
    self:setTimeUp()
    self:attack5ArmControl(event.unit)
    return 1
end

function class:setTimeUp()
    if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TIME_UP_ID].used then
        self:execTrigger(self.TIME_UP_ID)
    end
end

----: update :---->>>>
function class:attack5ArmControl(unit)
    if self.isLockOn then self:boneRotation(unit,"head") end
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

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    --if event.spineEvent == "setFire" then self:setFire(event.unit) end
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "startFire" then self:startFire(event.unit) end
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

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.gameUnit:setInvincibleTime(0)
    self.attack2FLG = false
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if self.HpFlgAddSp > 0 then
        event.unit:addSP(self.HpFlgAddSp)
        self.HpFlgAddSp = 0
    end

    if event.index == 2 then
        self.attack2FLG = true
        for i = 0,6 do
            self.attack2Paralyze[i] = false
        end
    end

    if event.index == 6 then
        self.attack6FLG = true
        self.HpFlgAddSp = self.spValue
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self.attack6Damage[i] = myTeamUnit:getHP() * 0.05
            end
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end
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
    self.attack2FLG = false
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 3 and self.isRage and not self.cutInFLG then
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end

    if event.index == 3 then
        self.skill3FLG = true
    end

    if self.isRage then
        self.isRage = false
    end

    self.cutInFLG = false
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    if self.isRage then
        skillIndex = 2
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
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
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

----// attackDamageValue //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.attack6FLG then
        event.value = self.attack6Damage[event.enemy:getIndex()]
    end
    if self.attack2FLG then
        if not self.attack2Paralyze[event.enemy:getIndex()] then
            self.attack2Paralyze[event.enemy:getIndex()] = true
            local n = math.random(1,2)
            if n == 1 then
                --self:execAddBuff(event.enemy,self.PARALYZE_BUFF_LIST[1])
            end
        end
    end
    if self.skill3FLG then
        self:execAddBuff(event.enemy,self.PARALYZE_BUFF_LIST[2])
    end
    return event.value
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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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