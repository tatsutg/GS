local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX化14章エミー", version=1.9, id=1404016});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK1 = 50,ATTACK3 = 50}
    },
    ADVANCED = {
        { ATTACK4 = 50,ATTACK5 = 50},
        { ATTACK5 = 50,ATTACK6 = 50},
        { ATTACK4 = 50,ATTACK6 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    },
    ADVANCED = {
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP90_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 17,---与ダメアップ
        VALUE = 20,
        DURATION = 99999,
        ICON = 26
    }
    self.HP70_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 23,---クリティカル耐性
        VALUE = -20,
        DURATION = 99999,
        ICON = 188
    }
    self.HP50_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 17,---与ダメアップ
        VALUE = 20,
        DURATION = 99999,
        ICON = 26,
        FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
    }
    self.HP30_BUFF_LIST1 = {
        ID = 0,
        BUFF_ID = 23,---クリティカル耐性
        VALUE = -40,
        DURATION = 99999,
        ICON = 188
    }
    self.HP30_BUFF_LIST2 = {
        ID = 0,
        BUFF_ID = 15,---防御力アップ
        VALUE = 30,
        DURATION = 99999,
        ICON = 5
    }
    self.HP10_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 28,---攻撃速度
        VALUE = 20,
        DURATION = 99999,
        ICON = 7
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 14050,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 30,
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
    self.PROTECT_KILLER_BUFF_LIST = {
        [1] = {
            ID = 1404015,
            BUFF_ID = 21, -- 被ダメージアップ
            VALUE = 5000,
            DURATION = 30,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 267
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "病気状態のとき被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージの大きい者をターゲット"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのクリティカル率アップ"})
    }
    self.HP90_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP90_MESSAGE1 or "与ダメージアップ"})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "クリティカル耐性アップ"})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "もういいや…全部、壊しちゃえ…",
                             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "与ダメージアップ"})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカル耐性・防御力アップ"})
    }
    self.HP10_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE1 or "奥義上昇量・攻撃速度アップ"})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "これで終わり…なの…？",
                             COLOR = Color.magenta})
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
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        },
        [5] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
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
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isRage = true
        self.gameUnit:addSP(100)
        self:execAddBuff(self.gameUnit,self.HP90_BUFF_LIST)
        self.isInvincible = true
        self:showMessage(self.HP90_MESSAGE_LIST)
    end
end

function class:hp70(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isRage = true
        self.gameUnit:addSP(100)
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_LIST)
        self.isInvincible = true
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isAngry = true
        self.gameUnit:addSP(100)
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_LIST)
        self.isInvincible = true
        self:showMessage(self.HP50_MESSAGE_LIST)
        ---パワーアップモード
        self.isAdvanced = true
        self:initAttackWeight({ADVANCED = 100})
        self:initSkillWeight({ADVANCED = 100})
    end
end

function class:hp30(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isFury = true
        self.gameUnit:addSP(100)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST1)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST2)
        self.isInvincible = true
        self:showMessage(self.HP30_MESSAGE_LIST)
    end
end

function class:hp10(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isFury = true
        self.gameUnit:addSP(100)
        self:execAddBuff(self.gameUnit,self.HP10_BUFF_LIST)
        self.spValue = 30
        self.gameUnit:setAttackDelay(2)
        self.isInvincible = true
        self:showMessage(self.HP10_MESSAGE_LIST)
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
    event.unit:setAttackDelay(10);---アタックディレイ
    --event.unit:addSP(20)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isAngry = false
    self.isRage = false
    self.isFury = false
    self.isInvincible = false
    self.burstPoint = 0
    self.isAdvanced = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    --自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}

    self.stateName = "NORMAL"

    self.breakSkip = false

    self.bugCheckFLG = false
    --self:bugChecker()
    return 1
end

function class:addProtectKiller()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            --self:execAddBuff(myTeamUnit,self.PROTECT_KILLER_BUFF_LIST[1])
        end
    end
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
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    --event.unit:setNextAnimationName("changein")
    event.unit:setNextAnimationEffectName("change_in")
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit.m_breaktime == 0 then
        self:HPTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("idle_A");
    end
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("back_A");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
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
    if event.index == 4 then
        event.unit:setNextAnimationName("attack1_A")
        event.unit:setNextAnimationEffectName("1-attack1")
    elseif event.index == 5 then
        event.unit:setNextAnimationName("attack2_A")
        event.unit:setNextAnimationEffectName("1-attack2")
    elseif event.index == 6 then
        event.unit:setNextAnimationName("attack3_A")
        event.unit:setNextAnimationEffectName("1-attack3")
    end

    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        if self.isInvincible then---HPフラグでの奥義後のみ
            event.unit:addSP(self.burstPoint)---奥義ゲージ引き継ぎ
            self.burstPoint = 0
            ---ターゲット初期化
            local target = self:checkTargetUnit()
            local index = target:getIndex() + (target:getBaseID3() * 10)
            self.targetUnitList[index].dps = 0
            ---ホストのみ
            if megast.Battle:getInstance():isHost() then
                local nextTarget = self:checkTargetUnit()
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,nextTarget:getIndex())---ゲストにターゲットを送る
                event.unit:setHateTarget(nextTarget)
                event.unit:updateHateTarget();
            end
            self.isInvincible = false---無敵解除
        end
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addProtectKiller()
    return 1
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget()
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

    if event.index == 1 and self.isAngry then
        self.isAngry = false
    elseif event.index == 2 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
    end

    if self.isAdvanced then
        if event.index == 1 then
            event.unit:setNextAnimationName("skill1_A")
            event.unit:setNextAnimationEffectName("1-skill1")
        elseif event.index >= 2 then
            event.unit:setNextAnimationName("skill2_A")
            event.unit:setNextAnimationEffectName("1-skill2")
        end
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self:addProtectKiller()
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isAngry then
        skillIndex = 1
    elseif self.isRage then
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
    if self.isInvincible then
        local cond94 = event.unit:getTeamUnitCondition():findConditionWithType(94);
        if cond94 ~= nil then
            event.value = event.value * 0.1
        else
            event.value = 0
        end
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
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(self.TARGET_BUFF_LIST1.ID)
                end
            end
        end
    end
    ------
    return event.value
end

function class:receive5(args)
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
    if self.isInvincible then
        event.value = 0
    end
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
    --[[
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    ]]--
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
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
    for i,value in ipairs({89,91,96}) do
        local condition = unit:getTeamUnitCondition():findConditionWithType(value)
        if condition ~= nil then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
    end
end

function class:bugChecker()
    self.bugCheckFLG = true
    self:activeSkillChecker()
end

function class:activeSkillChecker()
    local count = 0
    local anotherCount = 0
    local anotherTable = {}
    for attack,num in pairs(self.ACTIVE_SKILLS) do
        count = count + 1
        anotherTable[num] = attack
    end
    for i,v in pairs(anotherTable) do
        anotherCount = anotherCount + 1
    end
    if anotherCount ~= count then
        summoner.Utility.messageByEnemy("アクティブスキルエラー")
    else
        summoner.Utility.messageByEnemy("アクティブスキルOK")
    end
end

class:publish();

return class;