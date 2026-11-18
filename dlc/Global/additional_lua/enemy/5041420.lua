local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="虹天景・封神域_天閻神マールゼクス", version=2.0, id=5041420});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    FIRST = {
        { ATTACK1 = 50},
        { ATTACK2 = 50}
    },
    DEFAULT = {
        { ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50, SKILL2 = 50,SKILL3 = 50 }
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
    SKILL4 = 8,
    SKILL5 = 5,
    SKILL6 = 6,
    SKILL7 = 7
}

class.cutInSkill = {
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 5041420,
            BUFF_ID = 21,---魔法耐性アップ
            VALUE = -50,
            DURATION = 99999,
            ICON = 22,
            SCRIPT = {
                SCRIPT_ID = 3
            }
        },
        [2] = {
            ID = 0,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 15,
            ICON = 79
        }
    }

    self.TARGET_BUFF_LIST1 = {
        ID = 14050,
        BUFF_ID = 21, -- 被ダメージ
        VALUE = 50,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 14050,
        BUFF_ID = 0, -- 被ダメージ
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
        isPlayer = messageBox.isPlayer or false,
        ICON = messageBox.ICON or nil
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "パーティーの属性数が多いほど、ボスの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "鉄壁状態：ブレイクで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲット：与ダメージが大きいほど、被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "魔法耐性アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！鉄壁状態解除！", COLOR = Color.red})
    }
    self.BURN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BURN_MESSAGE1 or "燃焼耐性低下", COLOR = Color.red, ICON = 76})
    }
    self.FREEZE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "氷結耐性低下", COLOR = Color.red, ICON = 75})
    }
    self.POISON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POISON_MESSAGE1 or "毒耐性低下", COLOR = Color.red, ICON = 69})
    }
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

function class:hp70(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 5
        self.hpFLG = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:showMessage(self.HP70_MESSAGE_LIST)
        self.spValue = 30;---addSPの量
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 6
        self.hpFLG = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 7
        self.hpFLG = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self.spValue = 40;---addSPの量
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.hpFLG = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(60)
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
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    self:initAttackWeight({FIRST = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.hpSkill = 0
    self.hpFLG = false

    self.saveBP = 0
    event.unit:addNumBreakBadge(1)

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

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.damageBox = {
        [4] = 1,
        [3] = 0.5,
        [2] = 0.2,
        [1] = 0.1
    }
    self.elementCount = self:enemyElementCount(event.unit)
    return 1
end

function class:enemyElementCount(unit)
    self.elementBox = {}
    for i = 1,5 do
        self.elementBox[i] = false
    end

    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i,true)
        if myTeamUnit ~= nil then
            self.elementBox[myTeamUnit:getElementType()] = true
        end
    end
    local count = 0
    for i = 1,5 do
        if self.elementBox[i] then
            count = count + 1
        end
    end
    return count
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
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
            if self.deadCount >= 50 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    ---HP奥義中は常に無敵
    if self.hpFLG then
        self.gameUnit:setInvincibleTime(10)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "endless" then
        self:endless(event.unit);
    end

    if event.spineEvent == "silence" then
        self:silence(event.unit);
    end

    if event.spineEvent == "back" then
        event.unit:setPosition(-400,-70);
    end
    return 1;
end

function class:endless(unit)
    local ob1 = unit:addOrbitSystemWithFile("50024Skill4Ef","skill4");
    local ob2 = unit:addOrbitSystemCameraWithFile("50024Skill4Ef2","skill4",false);
    local ob3 = unit:addOrbitSystemWithFile("50024Skill4Ef3","skill4");
    local ob4 = unit:addOrbitSystem("skill4Effect",0);
end

function class:silence(unit)
    --全員沈黙させる
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,92,100,20,0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    event.unit:setNextAnimationName("back1")
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
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        self.hpFLG = false
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

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
        self.hpFLG = false
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

    if event.index == 1 or event.index == 5 then
        self:weakenBadCondition(60,-30)
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("3-skill1")
        self:showMessage(self.BURN_MESSAGE_LIST)
    elseif  event.index == 2 or event.index == 6 then
        self:weakenBadCondition(59,-30)
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("3-skill2")
        self:showMessage(self.FREEZE_MESSAGE_LIST)
    elseif  event.index == 3 or event.index == 7 then
        self:weakenBadCondition(53,-30)
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("3-skill3")
        self:showMessage(self.POISON_MESSAGE_LIST)
    elseif event.index == 4 then
        self.lastSkillFLG = true
        self:stun(event.unit)
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

function class:stun(unit)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[2])
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
    return 1
end

---状態異常耐性---
function class:weakenBadCondition(buffID,value)
    local BUFF_LIST = {
        ID = 50414000 + (buffID * 10),
        BUFF_ID = buffID,
        VALUE = value,
        DURATION = 99999,
        ICON = buffID + 16,
        MAX = 10
    }
    local BUFF_LIST2 = {
        ID = 50414001 + (buffID * 10),
        BUFF_ID = buffID + 49,
        VALUE = value,
        DURATION = 99999,
        ICON = 0,
        MAX = 10
    }
    self:addBuffWithProtector(BUFF_LIST)
    self:addBuffWithProtector(BUFF_LIST2)
end

function class:addBuffWithProtector(buffBox)
    local team = megast.Battle:getInstance():getTeam(true)
    local FLG = false
    local count = 1
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
                count = count + 1
            end
        end
    end
    ---庇うユニットがいる場合
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for i = 1,count do
                        self:execAddBuff(teamUnit,buffBox)
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,buffBox)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if event.enemy == self:checkTargetUnit() then
        local percent = self:checkDamage(self:checkTargetUnit())/self.gameUnit:getCalcHPMAX()
        event.value = event.value * ((1.3 + percent)^2 - 0.5)
        --summoner.Utility.messageByEnemy(math.floor(percent*100).."/"..math.floor(((1.3 + percent)^2 - 0.5)*100))
    end
    return event.value
end

function class:attackDamageValue_OrbitSystem(event)
    if event.enemy == self:checkTargetUnit() then
        local percent = self:checkDamage(self:checkTargetUnit())/self.gameUnit:getCalcHPMAX()
        event.value = event.value * ((1.3 + percent)^2 - 0.5)
        --summoner.Utility.messageByEnemy(math.floor(percent*100).."/"..math.floor(((1.3 + percent)^2 - 0.5)*100))
    end
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.unit:getNumBreakBadges() == 1 then
        event.value = 1
    end

    event.value = event.value * self.damageBox[self.elementCount]

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

function class:checkDamage(target)
    for i,v in pairs(self.targetUnitList) do
        if v.unit == target then
            return v.dps
        end
    end
    return 0
end

---ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
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
    ---一度ブレイクしたら二度としない
    if event.unit:getNumBreakBadges() == 0 then
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
    ---一度ブレイクしたら二度としない
    if event.unit:getNumBreakBadges() == 0 then
        return 0
    end
    self.gameUnit:removeNumBreakBadge()
    self:initAttackWeight({DEFAULT = 100})
    self:showMessage(self.BREAK_MESSAGE_LIST)
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
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR,messageBox.ICON);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR,messageBox.ICON);
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
            if count > buffBox.MAX then
                count = buffBox.MAX
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