local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒クエスト5／緑命竜エルプネウマス", version=1.3, id=5040920});
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
    SKILL3 = 5
}

class.cutInSkill = {
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 500131,
            BUFF_ID = 17,---与ダメージアップ
            VALUE = 0,
            DURATION = 99999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 500132,
            BUFF_ID = 201,---猛毒
            VALUE = 50 * 15,
            DURATION = 99999,
            ICON = 301,
            SCRIPT = {
                SCRIPT_ID = 601,
                VALUE1 = 1,
                VALUE2 = 5
            }
        },
        [3] = {
            ID = 500133,
            BUFF_ID = 21,---被ダメージアップ
            VALUE = 20,
            DURATION = 99999,
            ICON = 139,
            COUNT = 1,
            MAX = 10
        },
        [4] = {
            ID = 500134,
            BUFF_ID = 89,---気絶
            VALUE = 100,
            DURATION = 20,
            ICON = 79
        },
        [5] = {
            ID = 500135,
            BUFF_ID = 13,---攻撃力ダウン
            VALUE = -150,
            DURATION = 99999,
            ICON = 4
        },
        [6] = {
            ID = 500136,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end ---オーラ
        },
        [7] = {
            ID = 0,
            BUFF_ID = 7,
            VALUE = 0.2,
            DURATION = 30,
            ICON = 35,
            SCRIPT = {
                SCRIPT_ID = 238,
                VALUE1 = 0
            }
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージ無効化無効・精霊族キラー"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "ダークコロック：クリティカルダメージ無効"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "ダークコロック：毒状態のとき被ダメージ・BE量アップ"
        })
    }

    self.SKILL1_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "毒竜のダメージアップ"
        })
    }

    self.SKILL2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "毒竜のHPが回復する"
        })
    }

    self.HP90_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP90_MESSAGE1 or "猛毒の霧が立ち込める"
        })
    }

    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "毒竜の奥義上昇量アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "パーティの攻撃力大幅ダウン"
        })
    }

    self.SUMMON1_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON1_MESSAGE1 or "ドゥーラが加勢した",
            COLOR = Color.green
        })
    }

    self.SUMMON2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON2_MESSAGE1 or "ダークコロックが加勢した",
            COLOR = Color.magenta
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp90(status) end,
            HP = 90,
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

function class:hp90(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self:removeBadCondition(self.gameUnit)
        self:enemyAddBuffCheck(self.gameUnit,self.BUFF_BOX_LIST[2])
        self.BUFF_BOX_LIST[3].COUNT = 1
        self.BUFF_BOX_LIST[3].VALUE = 20
        self:enemyAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP90_MESSAGE_LIST)
    end
end

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self:removeBadCondition(self.gameUnit)
        self:enemyAddBuffCheck(self.gameUnit,self.BUFF_BOX_LIST[2])
        self.BUFF_BOX_LIST[3].COUNT = 2
        self.BUFF_BOX_LIST[3].VALUE = 40
        self:enemyAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP90_MESSAGE_LIST)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self:removeBadCondition(self.gameUnit)
        self:enemyAddBuffCheck(self.gameUnit,self.BUFF_BOX_LIST[2])
        self.BUFF_BOX_LIST[3].COUNT = 3
        self.BUFF_BOX_LIST[3].VALUE = 60
        self:enemyAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP90_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        self:removeBadCondition(self.gameUnit)
        self.spValue = 50;---addSPの量
        self:enemyAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

---状態異常回復メソッド
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

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:enemyAddBuffCheck(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
            if buff == nil then
                self:execAddBuff(myTeamUnit,buffBox)
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
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(6);---アタックディレイ
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

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true

    self.hpSkill = 0

    self.saveBP = 0

    self.isLockOn = false
    self.isFireEnd = false
    self.shotAngle = 0
    self.neckAngle = 0
    self.neckAngleDefault = 321
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    --if event.spineEvent == "setFire" then self:setFire(event.unit) end
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    --if event.spineEvent == "startFire" then self:startFire(event.unit) end
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

    if event.index == 1 then
        if not self:findEnemy(5040922) then
            if self:MultipleSummon(event.unit,5040922,1) then
                self:showMessage(self.SUMMON2_MESSAGE_LIST)
            end
        end
    elseif event.index == 3 then
        if not self:findEnemy(5040921) then
            if self:MultipleSummon(event.unit,5040921,1) then
                self:showMessage(self.SUMMON1_MESSAGE_LIST)
            end
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
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
        self.BUFF_BOX_LIST[1].COUNT = self.BUFF_BOX_LIST[1].COUNT + 1
        if self.BUFF_BOX_LIST[1].COUNT > 10 then
            self.BUFF_BOX_LIST[1].COUNT = 10
        end
        self.BUFF_BOX_LIST[1].VALUE = 3 * (self.BUFF_BOX_LIST[1].COUNT ^ 2)
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.SKILL1_MESSAGE_LIST)
        if self:MultipleSummon(event.unit,5040922,2) then
            self:showMessage(self.SUMMON2_MESSAGE_LIST)
        end
    end

    if event.index == 2 then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        local index = 0
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                index = i
            end
        end
        self:execAddBuff(myTeam:getTeamUnit(index),self.BUFF_BOX_LIST[4])
        self:showMessage(self.SKILL2_MESSAGE_LIST)
        if self:MultipleSummon(event.unit,5040921,2) then
            self:showMessage(self.SUMMON1_MESSAGE_LIST)
        end
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[7])
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("attack5")
        event.unit:setNextAnimationEffectName("1-attack5")
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
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    megast.Battle:getInstance():waveEnd(true);
    return 1
end

function class:receive4(args)
    megast.Battle:getInstance():waveEnd(true);
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

    if buffBox.FUNC ~= nil then buffBox.FUNC(buff) end
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

function class:summon(unit,unitID)
    local flg = false
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
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

function class:findEnemy(enemyID)
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == enemyID then
                return true
            end
        end
    end
    return false
end

class:publish();

return class;