local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="紋章宮ゼ＝レムナ", version=1.3, id=4001416});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK1 = 50,ATTACK2 = 50}
    },
    HP50 = {
        { ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK3 = 50},
        { ATTACK1 = 50,ATTACK2 = 50}
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
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8,
    SKILL4 = 5
}

class.cutInSkill = {
    [1] = 1,
    [3] = 1
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 500851,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 99999,
            ICON = 79
        },
        [2] = {
            ID = 500851,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.DAMAGE_BUFF_LIST = {
        [1] = {
            ID = 500852,
            BUFF_ID = 129,
            VALUE = 2,
            DURATION = 99999,
            ICON = 180,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [2] = {
            ID = 500852,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,
            VALUE = -80,
            DURATION = 10,
            ICON = 4
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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性・神族キラー"}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "編成の右側3体を優先してロック"})
    }
    self.LOCK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE1 or "をロック：ブレイクで解除",
                                   COLOR = Color.red})
    }
    self.BREAK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイクでロック状態を解除！",
                                   COLOR = Color.red})
    }
    self.BREAK2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.BREAK2_MESSAGE1 or "ブレイク中、被ダメージアップ！",
                                   COLOR = Color.red})
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
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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
        self.isRage = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
        self:initAttackWeight({HP50 = 100})
        self.gameUnit:setAttackDelay(7)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.isDead = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
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
    event.unit:setAttackDelay(8);---アタックディレイ
    event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self.isDead = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.saveBP = 0

    self.breakFLG = false

    self.skill4FLG = false

    self.phantasmTable = {}

    self.loopCheck = 0
    
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    if self.breakFLG then
        ---奥義5
        if event.unit.m_breaktime == 0 and not self.isDead then
            self:removeAllBadstatus(event.unit)
            self.breakFLG = false
            self.isFury = true
            self.saveBP = 40
            self.gameUnit:addSP(100)
            self.gameUnit:setInvincibleTime(30)
        end
    end
    self:phantasmLockUpdate()
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[2].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 15 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    return 1
end

function class:phantasmLockUpdate()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                if self.phantasmTable[i] then
                    count = count + 1
                    self:itemCtReset(myTeamUnit)
                    myTeamUnit:getNormalSkill():resetCooltime()
                    myTeamUnit:setBurstPoint(0)
                    if myTeamUnit:getPositionX() < self.gameUnit:getPositionX() + 100 then
                        myTeamUnit:setPositionX(self.gameUnit:getPositionX() + 100)
                    end
                else
                    myTeamUnit:takeGrayScale(1);
                end
            end
        else
            if self.phantasmTable[i] ~= nil then
                self.phantasmTable[i] = false
            end
        end
    end
    return 1;
end

function class:itemCtReset(target)
    for n = 0,2 do
        local item = target:getItemSkill(n)
        if item ~= nil then
            item:resetCooltime()
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if not self.afterSkillFLG then
        if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    end
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

    if event.index == 3 then
        event.unit:setNextAnimationName("attack4");
        event.unit:setNextAnimationEffectName("1-attack4")
    elseif event.index == 4 then
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        ---生存ユニットが全員ロック状態の場合強制敗北
        local myTeam = megast.Battle:getInstance():getTeam(true);
        local FLG = false
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if not self.phantasmTable[i] then
                    FLG = true
                end
            end
        end
        if not FLG then
            event.unit:setNextAnimationName("idle");
            event.unit:setNextAnimationEffectName("1-skill2")
            self:initPhantasmLock()
            for n = 0,7 do
                local nTeamUnit = myTeam:getTeamUnit(n);
                if nTeamUnit ~= nil then
                    self:removeConditionAll(nTeamUnit,83)
                end
            end
            self:allDead()
        end
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    
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

----// takeIdle //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end

----// takeBack //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 0
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

    if event.index == 1 and self.isRage then
        ---HP50
        self.isRage = false
    elseif event.index == 4 and self.isFury then
        ---奥義5
        self.isFury = false
    end

    if event.index == 2 then
        if megast.Battle:getInstance():isHost() then
            self:phantasmLock()
        end
    elseif event.index == 3 then
        self.gameUnit:setInvincibleTime(30)
        self.lastSkillFLG = true
    elseif event.index == 4 then
        self.skill4FLG = true
        event.unit:setNextAnimationName("attack6");
        event.unit:setNextAnimationEffectName("1-attack6")
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 1
    elseif self.isFury then
        skillIndex = 4
    elseif self.isDead then
        skillIndex = 3
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
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

function class:phantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local count = 0
    ---庇うユニットがいる場合
    for i = 0,7 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                local target = cond:getProtectTarget()
                if self.phantasmTable[target] == false then
                    count = 100
                    self:phantasmLockBuff(target)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target);
                    break;
                end
            end
        end
    end
    local FLG = true
    ---右側3体を優先
    for i = 1,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                ---右3体生存ユニットにロック状態でないものがいる場合
                if not self.phantasmTable[i] then
                    FLG = false
                    break;
                end
            end
        end
    end
    ---庇うユニットがいない場合
    while count < 100 do
        count = count + 1
        local rand = LuaUtilities.rand(1,4)
        if FLG then rand = 0 end
        if self.phantasmTable[rand] ~= nil then
            if self.phantasmTable[rand] == false then
                count = 100
                self:phantasmLockBuff(rand)
                megast.Battle:getInstance():sendEventToLua(self.scriptID,5,rand);
            end
        end
    end
    return 1;
end

function class:phantasmLockBuff(rand)
    ---ターゲットにロック状態バフなど付与
    local myTeam = megast.Battle:getInstance():getTeam(true);
    self.phantasmTable[rand] = true
    local myTeamUnit = myTeam:getTeamUnit(rand)
    if myTeamUnit ~= nil then
        myTeamUnit:takeGrayScale(0.1);
        self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1])
        self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[1])
        self:execShowFixedMessage(self.LOCK_MESSAGE_LIST[1],myTeamUnit:getUnitName())
        self:lockPosition(self.gameUnit,myTeamUnit)
    end
    ---全体から庇うを解除
    for n = 0,7 do
        local nTeamUnit = myTeam:getTeamUnit(n);
        if nTeamUnit ~= nil then
            self:removeConditionAll(nTeamUnit,128)
        end
    end
end

function class:lockPosition(unit,target)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    target:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
    return 1
end

function class:receive5(args)
    self:phantasmLockBuff(args.arg)
    return 1
end

function class:removeConditionAll(myTeamUnit,condType)
    local count = 1
    while count > 0 do
        count = 0
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithType(condType) ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithType(condType))
                count = count + 1
                self.loopCheck = self.loopCheck + 1
                if self.loopCheck >= 100 then
                    self.loopCheck = 0
                    break
                end
            end
        end
    end
    self.loopCheck = 0
end

----// attackDamageValue //-----------------------------------------------------------------------------
-- 条件 : 本体の攻撃Hit時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃対象  event.value / 与ダメージ量
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.skill4FLG then
        self.skill4FLG = false
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[3])
                self:execAddBuff(myTeamUnit,self.BUFF_LIST[1])
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 1000)
            end
        end
    end
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.unit.m_breaktime == 0 then
        event.value = event.value * 0.5
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
    event.value = event.value * 0.2
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
    self:showMessage(self.BREAK2_MESSAGE_LIST)
    ---ファンタズムロック初期化
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                if self.phantasmTable[i] then
                    self:showMessage(self.BREAK_MESSAGE_LIST)
                    break;
                end
            end
        end
    end
    self:initPhantasmLock()
    self.breakFLG = true
    return 1
end

function class:initPhantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
            self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2])
            self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[2])
            myTeamUnit:takeGrayScale(1);
        end
    end
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

function class:execShowFixedMessage(messageBox,str)
    local fixedMessage = str..messageBox.MESSAGE
    summoner.Utility.messageByEnemy(fixedMessage,messageBox.DURATION,messageBox.COLOR);
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

function class:removeAllBadstatus(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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