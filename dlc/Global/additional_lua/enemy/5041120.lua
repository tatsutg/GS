local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="星天景・刻神峰_フォンギオン", version=1.3, id=5041120});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK4=50},
        {ATTACK1=50, ATTACK2=50},
        {ATTACK2=50, ATTACK3=50},
        {ATTACK1=50, ATTACK3=50}
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        {SKILL2=50}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

class.cutInSkill = {
    [3] = 1,
    [4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 23,---クリティカル耐性
            VALUE = -200,
            DURATION = 99999,
            ICON = 188
        },
        [2] = {
            ID = 0,
            BUFF_ID = 17,---気絶
            VALUE = 200,
            DURATION = 99999,
            ICON = 26
        },
        [3] = {
            ID = 0,
            BUFF_ID = 15,--- 防御力
            VALUE = 200,
            DURATION = 99999,
            ICON = 5
        },
        [4] = {
            ID = 50411204,
            BUFF_ID = 32,---命中率DOWN
            VALUE = -60,
            DURATION = 99999,
            ICON = 15,
            MAX = 10
        }
    }

    self.STUN_BUFF_LIST = {
        ID = 50411201,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 60,
        ICON = 0
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
        DURATION = 99999,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "自然回復キラー・ダメージ無効化無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ミルザ：被クリティカルダメージアップ", COLOR = Color.red})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "与ダメージアップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "防御力アップ", COLOR = Color.yellow})
    }
    self.SUMMON1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON1_MESSAGE1 or "ミルザが加勢した", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "ターゲットの命中率ダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        },
        [4] = {
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.buffNumber = 1
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:removeBadCondition(self.gameUnit)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.buffNumber = 2
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:removeBadCondition(self.gameUnit)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.buffNumber = 3
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:removeBadCondition(self.gameUnit)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
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
    event.unit:setAttackDelay(9);---アタックディレイ
    event.unit:addSP(100)---戦闘開始時の奥義ゲージ量
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

    self.hpSkill = 1
    self.buffNumber = 0

    self.saveBP = 0

    ---フォンギオンで使用する変数たち
    self.stopOrbit = nil;
    self.isStop = false;
    self.reverceMode = false;
    self.hitStopRegection = true;
    self.forceSkillNumber = 0;
    self.isReady = false
    self.Clock = nil;
    self:createClock(event.unit);

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end

function class:startWave(event)
    self.posX = event.unit:getPositionX()
    self.posY = event.unit:getPositionY()
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithID(-12) ~= nil then
                myTeamUnit:takeGrayScale(0.1)
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST.ID) == nil then
                    self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST)
                end
            else
                myTeamUnit:takeGrayScale(1)
                myTeamUnit:getTeamUnitCondition():removeConditionWithID(50411201)
            end
        end
    end
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[4].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 30 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    if self.posX ~= nil then
        event.unit:setPosition(self.posX,self.posY)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "endless" then self:endless(event.unit); end
    if event.spineEvent == "cameraControll" then self:cameraControll(event.unit); end
    if event.spineEvent == "showStopOrbit" then self:showStopOrbit(event.unit); end
    if event.spineEvent == "stop" then self:stop(event.unit); end
    if event.spineEvent == "reStart" then self:restart(event.unit); end
    if event.spineEvent == "clockAttack" then self.Clock:takeAttack(); end
    if event.spineEvent == "tickEnd" then self.Clock:tick(); end
    if event.spineEvent == "clockActionEnd" then self.Clock:takeBaseAnimation(); end

    if event.spineEvent == "reverce" then
        self.Clock:setVector(-1);
        self.Clock:takeSkill4();
    end

    if event.spineEvent == "reInit" then
        event.unit:setBreakPoint(event.unit:getBaseBreakCapacity());
        self.reverceMode = false;
        self.Clock:setVector(1);
        local HP = event.unit:getCalcHPMAX()
        if self.buffNumber == 3 then HP = HP / 2 end
        event.unit:setHP(HP);
    end

    if event.spineEvent == "reverceEnd" then
        self.Clock:setVector(1);
        self.hpSkill = 1
        self.gameUnit:addSP(100)
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

    if event.index == 2 then
        if self:teamCount() == 1 then
            self:summon(event.unit,5041121)
        end
    end

    if event.index == 4 then
        local target = self:randomPick()
        self:stun(event.unit,target,false,5)
        target:setBurstPoint(0)
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
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

function class:teamCount()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    local count = 0
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + 1
        end
    end
    return count
end

function class:randomPick()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local teamTable = {}
    local count = 0
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + 1
            teamTable[count] = myTeamUnit
        end
    end
    local result = math.random(1,count)
    return teamTable[result]
end

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
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
        self:stunAll(event.unit,false,10)
        self.gameUnit:setInvincibleTime(10)
        if self.buffNumber > 0 then
            if self.buffNumber == 1 then
                self:multipleSummon(event.unit,5041121,3)
                self:showMessage(self.HP60_MESSAGE_LIST)
            elseif self.buffNumber == 2 then
                self:multipleSummon(event.unit,5041121,4)
                self:showMessage(self.HP40_MESSAGE_LIST)
            elseif self.buffNumber == 3 then
                self:multipleSummon(event.unit,5041121,6)
                self:showMessage(self.HP20_MESSAGE_LIST)
                self.spValue = 40
            end
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[self.buffNumber])
            self.buffNumber = 0
        end
    end

    if event.index == 2 then
        local target = self:checkTargetUnit()
        self:stun(event.unit,target,false,5)
        self:execAddBuff(target,self.BUFF_BOX_LIST[4])
        self:showMessage(self.SKILL2_MESSAGE_LIST)
    end

    if event.index == 3 then
        self.lastSkillFLG = true
        self:stunAll(event.unit,true,10)
        self.gameUnit:setInvincibleTime(10)
    end

    if event.index == 4 then
        self:moveAll(event.unit)
        self.gameUnit:setInvincibleTime(10)
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:stun(unit,target,FLG,time)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    target:getTeamUnitCondition():addCondition(-12,92,100,time,0);
    if FLG then
        target:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
    end
end

function class:stunAll(unit,FLG,time)
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:stun(unit,myTeamUnit,FLG,time)
        end
    end
end

function class:moveAll(unit)
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
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
    event.value = self:adjustHpFlg(event.unit,event.value)
    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value end
    ---ユニットのダメージをテーブルに格納
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
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
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
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end
    return event.value
end

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end
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

---ご先祖ユニットまで遡る
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
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 0
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

function class:removeBadCondition(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for typeId = 89,97 do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                end
            end
        end
    end
end

--=====================================================================================================================================
--エンドレスの演出関連
function class:endless(unit)
    local bg = unit:addOrbitSystemWithFile("50086endless","BG_ENDLESS");
    bg:setZOrder(2);
    unit:addOrbitSystemCameraWithFile("50086endless","FONT_ENDLESS",false);
    unit:addOrbitSystemWithFile("50086endless","CutIN_ENDLESS");
    local ef = unit:addOrbitSystem("endlessEF",0);
    ef:setDamageRateOffset(0.001);
    ef:setZOrder(9000);
    self.Clock:takeEndless();
    unit:takeGrayScale(0.1);
end

function class:cameraControll(unit)
    unit:cameraLock(0,0.2,unit:getSkeleton():getBoneWorldPositionX("MAIN"),unit:getSkeleton():getBoneWorldPositionY("MAIN") -250);
end
--=====================================================================================================================================
--時止め関連
function class:showStopOrbit(unit)
    self.stopOrbit = unit:addOrbitSystem("skill1orbit",0);
    self.stopOrbit:setZOrder(2);
    self.hitStopRegection = true;
end

function class:stop(unit)
    self.isStop = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,92,100,13,0);
            uni:takeGrayScale(0.1);
            uni:takeHitStop(13);
        end
    end
end

function class:theWorld(unit)
    unit:takeGrayScale(0.1);
end

function class:canselled()
    self.isStop = false;
    if self.stopOrbit ~= nil then
        self.stopOrbit:takeAnimation(0,"skill1orbitCansel",false);
        self.stopOrbit = nil;
    end
    self:restart();
end

function class:restart()
    self.hitStopRegection = true;
    self.stopOrbit = nil;
    self.isStop = false;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:takeGrayScale(0.99);
        end
    end
end

--=====================================================================================================================================
--背後の時計関係
function class:createClock(unit)
    self.Clock = {
        object = nil,
        vector = 1,
        count = 0,

        setUp = function(clock)
            clock.object:takeAnimation(0,"base",true);
            clock.object:setZOrder(3);
            clock.object:setPosition(-260,-30);
        end,

        takeBaseAnimation = function(clock)
            clock.object:takeAnimation(0,"base",true);
        end,

        setVector = function(clock,vec)
            clock.vector = vec;
        end,

        tick = function(clock)
            local clockTime = clock.count%12;
            local nextClockTime = (clock.count + clock.vector)%12;
            clock.object:setSetupAnimationName(""..clockTime.."to"..nextClockTime);
            clock.object:takeAnimation(1,""..clockTime.."to"..nextClockTime,false);
            clock.count = clock.count + clock.vector;
        end,

        takeAttack = function(clock)
            clock.object:takeAnimation(0,"attack3",true);
        end,

        takeEndless = function(clock)
            clock.object:takeAnimation(0,"skill3",true);
        end,

        takeSkill4 = function(clock)
            clock.object:takeAnimation(0,"skill4",true);
        end

    }
    self.Clock.object = unit:addOrbitSystemWithFile("50086Clock","base");
    self.Clock:setUp();
    self.Clock:tick();
end
--=====================================================================================================================================

function class:multipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID)
    end
end

function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 5 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)
                self:showMessage(self.SUMMON1_MESSAGE_LIST)
                break
            end
        end
    end
end

class:publish();

return class;