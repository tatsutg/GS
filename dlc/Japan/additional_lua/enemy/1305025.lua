local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX化エミー", version=1.9, id=1305025});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50},
        { ATTACK2 = 50, ATTACK3 = 50},
        { ATTACK1 = 50, ATTACK3 = 50}
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
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9,
    SKILL4 = 10
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,
            VALUE = 30,
            DURATION = 99999,
            ICON = 3
        }
    }
    self.SKILL1_BUFF_LIST = {
        [1] = {
            ID = -1305015,
            BUFF_ID = 22,
            VALUE = 30,
            DURATION = 99999,
            ICON = 11
        },
        [2] = {
            ID = -1305015,
            BUFF_ID = 132,
            VALUE = 99999,
            DURATION = 99999,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "そう…逆らうのね",COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "奪い尽くしてやる",COLOR = Color.magenta})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "滅びなさい",COLOR = Color.magenta})
    }
    self.POWERUP1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POWERUP1_MESSAGE1 or "被ダメージ軽減・ダメージ無効化無効：気絶・ブレイクで解除"})
    }
    self.POWERUP2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POWERUP2_MESSAGE1 or "クリティカル率アップ：気絶・ブレイクで解除"})
    }
    self.STAN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.STAN_MESSAGE1 or "気絶でパワーアップモード解除成功！"})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイクでパワーアップモード解除成功！"})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "もういいや…全部、壊しちゃえ…",COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "攻撃力・奥義ゲージ増加量アップ"})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "これで終わり…なの…？",COLOR = Color.magenta})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        }
    }
    self.hpMarkers[30] = self.gameUnit:addNumHpMarker(0.3)
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:hp30(status)
    if status == "use3" then
        self.isRage = true
        self.gameUnit:addSP(100)
        self.spValue = 30;
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
        self:setInvincibleTimeWithIcon(self.gameUnit,7,self.showIcon)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self.gameUnit:removeHpMarker(self.hpMarkers[30])
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

    self.modeA = false
    self.isModeChange = false
    self.countTime = 0
    self.HP30FLG = false
    self.CutInFLG = false
    self.loopCheck = 0
    self.rateValue = 0
    self.burstSumAll = 0

    self.hpMarkers = {}

    self.BreakDamageCount = 0

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
    self.showIcon = false

    event.unit:addSP(0)
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
    self:HPTriggersCheck(event.unit)
    self:stanCheck(event.unit)
    self:modeChange(event.deltaTime)
    event.unit:setReduceHitStop(100,1)
    return 1
end

function class:stanCheck(unit)
    if unit:getTeamUnitCondition():findConditionWithType(89) ~= nil and self.modeA then
        self:removeModeA()
        self:showMessage(self.STAN_MESSAGE_LIST)
    end
end

function class:modeChange(deltaTime)
    for i,value in ipairs({89,91,96}) do
        local condition = self.gameUnit:getTeamUnitCondition():findConditionWithType(value)
        if condition ~= nil then
            self.isModeChange = false
            self.countTime = 0
        end
    end
    if self.isModeChange then
        self.countTime = self.countTime + deltaTime
        if self.countTime > 6 then
            self.isModeChange = false
            self.countTime = 0
            self:burstAbsorb()
            self:healSteal()
            self:execAddBuff(self.gameUnit,self.SKILL1_BUFF_LIST[2])
            if not self.modeA then
                self.modeA = true
                self:showMessage(self.POWERUP1_MESSAGE_LIST)
            elseif self.modeA then
                self:execAddBuff(self.gameUnit,self.SKILL1_BUFF_LIST[1])
                self:showMessage(self.POWERUP2_MESSAGE_LIST)
            end
        end
    end
end

function class:removeModeA()
    self.modeA = false
    self.burstSumAll = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    local countBlind = 1
    while countBlind > 0 do
        countBlind = 0
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(-1305015) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithID(-1305015))
                    countBlind = countBlind + 1
                end
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(-13050151) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithID(-13050151))
                    countBlind = countBlind + 1
                end
            end
        end
    end
end
function class:removePower()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    local countBlind = 1
    while countBlind > 0 do
        countBlind = 0
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(-13050151) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithID(-13050151))
                    countBlind = countBlind + 1
                end
            end
        end
    end
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.modeA then
        event.unit:setNextAnimationName("idle_A");
    end
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.modeA then
        event.unit:setNextAnimationName("back_A");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "idle2" then event.unit:takeAnimation(0,"idle2",true) end
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
    if self.modeA then
        if event.index == 1 then
            event.unit:setNextAnimationName("attack1_A")
            event.unit:setNextAnimationEffectName("1-attack1")
        elseif event.index == 2 then
            event.unit:setNextAnimationName("attack2_A")
            event.unit:setNextAnimationEffectName("1-attack2")
        elseif event.index == 3 then
            event.unit:setNextAnimationName("attack3_A")
            event.unit:setNextAnimationEffectName("1-attack3")
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.afterSkillFLG = false
    end
    if self.modeA then
        event.index = event.index + 3
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
    if not self.modeA and not self.isRage then
        if event.index == 1 then
            self.isModeChange = true
        elseif event.index == 2 then
            self:setInvincibleTimeWithIcon(self.gameUnit,7,self.showIcon)
        end
    elseif self.modeA and not self.isRage then
        if event.index == 1 then
            event.unit:setNextAnimationName("skill1_A")
            event.unit:setNextAnimationEffectName("1-skill1")
            self.isModeChange = true
        elseif event.index == 2 then
            event.unit:setNextAnimationName("skill2_A")
            event.unit:setNextAnimationEffectName("1-skill2")
            self:setInvincibleTimeWithIcon(self.gameUnit,7,self.showIcon)
        end
    end

    if event.index == 2 and self.isRage and not self.CutInFLG then
        self.CutInFLG = true
        self.isRage = false
        event.unit:takeSkillWithCutin(2,1);
        return 0
    end

    if not self.CutInFLG then
        if event.index == 1 then
            self:showMessage(self.SKILL1_MESSAGE_LIST)
        elseif event.index == 2 then
            self:showMessage(self.SKILL2_MESSAGE_LIST)
        end
    end

    self.CutInFLG = false
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    if self.modeA then
        event.index = event.index + 2
    end
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
---奥義ゲージ吸収---
function class:burstAbsorb()
    local burstSum = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local burstPoint = myTeamUnit:getBurstPoint() / 2
            myTeamUnit:setBurstPoint( burstPoint )
            burstSum = burstSum + burstPoint
        end
    end
    self.burstSumAll = self.burstSumAll + burstSum
    if megast.Battle:getInstance():isHost() then
        self:removePower()
        self:splitBuff( self.burstSumAll )
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,self.burstSumAll)
    end
end

function class:receive5(args)
    self:removePower()
    self:splitBuff( args.arg )
    return 1
end

function class:splitBuff(point)
    local rest = point % 100
    local times = (point / 100) - (rest / 100)
    local buffBox = {
        ID = -13050151,
        BUFF_ID = 17,
        VALUE = 100,
        DURATION = 99999,
        ICON = 26
    }
    for i = 0,times do
        if i == times then
            buffBox.VALUE = rest
            if buffBox.VALUE > 0 then
                self:execAddBuff(self.gameUnit,buffBox)
            end
        else
            self:execAddBuff(self.gameUnit,buffBox)
        end
    end
end

----------
---自然回復吸収---
function class:healSteal()
    self.rateValue = 0
    local healSum = 0
    local healBuff = {
        ID = -1305015,
        BUFF_ID = 7,
        VALUE = 0,
        DURATION = 99999,
        ICON = 35
    }
    local rateBuff = {
        ID = -1305015,
        BUFF_ID = 7,
        VALUE = 0,
        DURATION = 99999,
        ICON = 35,
        SCRIPT = {
            SCRIPT_ID = 238,
            VALUE1 = 0
        }
    }
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local condition = myTeamUnit:getTeamUnitCondition():findConditionWithType(7)
            if condition ~= nil then
                healSum = healSum + self:checkCondition(myTeamUnit,7)
                self:removeConditionAll(myTeamUnit,7)
            end
        end
    end
    if healSum ~= 0 then
        healBuff.VALUE = healSum * 3
        self:execAddBuff(self.gameUnit,healBuff)
    end
    if self.rateValue ~= 0 then
        rateBuff.VALUE = self.rateValue / 6
        self:execAddBuff(self.gameUnit,rateBuff)
    end
end

function class:checkCondition(unit,condType)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    local condValue = 0

    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getValue() > 0 then
                if cond:getScriptID() == 238 then
                    self.rateValue =  self.rateValue + cond:getValue()
                    cond:setValue(0)
                    cond:setThumbnailID(0)
                elseif cond:getConditionTypeAsInt() == condType then
                    condValue = condValue + cond:getValue()
                    cond:setValue(0)
                    cond:setThumbnailID(0)
                end
            end
        end
    end
    return condValue
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
end

---------
----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.modeA then
        event.value = event.value * 0.8
    end
    if self.isModeChange then
        event.value = 1
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
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    local a = unit:getHP() - border
    local b = value - a
    local c = value - b
    return c
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.isModeChange then
        event.value = 0
    end
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() == stopBorder then
            return 0
        end
    end
    self.isModeChange = false
    self.countTime = 0
    if self.modeA then
        self:removeModeA()
        self:showMessage(self.BREAK_MESSAGE_LIST)
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    event.unit:setNextAnimationName("changeout")
    event.unit:setNextAnimationEffectName("change_out")
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
---無敵時間(アイコン表示可)---
function class:setInvincibleTimeWithIcon(unit,time,icon)
    if icon then
        self.iconNumber = 200
    else
        self.iconNumber = 0
    end
    self.INVINCIBLE_BUFF_BOX_LIST = {
        [1] = {
            ID = 209032,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = time,
            ICON = self.iconNumber
        }
    }
    unit:setInvincibleTime(time)
    self:execAddBuff(unit,self.INVINCIBLE_BUFF_BOX_LIST[1])
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