local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="26章_真EX_覇罪皇ギアベール", version=1.3, id=2605022});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 }
    },
    CHANGED = {
        { ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    },
    CHANGED = {
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    SKILL1 = 8,
    SKILL2 = 9,
    SKILL3 = 10
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
            --COUNT = 1,
            --MAX = 5
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "人族からの被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "光属性以外へのダメージアップ", COLOR = Color.red})
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
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.gameUnit:addSP(100)
        if self.attack5Flg then
            self.hpSkill = 2
        else
            self.hpSkill = 3
        end
        --self.gameUnit:setInvincibleTime(7)
        self:showMessage(self.HP30_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 18;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

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
    self.buffDamageValRate = 0.1
    self.raceDamageValRate = 0.1

    self.battleTime = 0
    self.changeTime = 20
    self.changeFlg = false
    self.isChange = false
    self.attack5Flg = false
    self.addSpFlg = false

    self.mode = 1
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.battleTime = 0
    self.elementCount = self:enemyElementCount(event.unit)
    --summoner.Utility.messageByEnemy(self.elementCount);
    return 1
end

function class:enemyElementCount(unit)
    self.elementBox = {}
    for i = 1,5 do
        self.elementBox[i] = 0
    end

    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    --PT属性数を出す
    local unitNum = 0
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i,true)
        if myTeamUnit ~= nil then
            unitNum = unitNum + 1
            self.elementBox[myTeamUnit:getElementType()] = self.elementBox[myTeamUnit:getElementType()] + 1
        end
    end
    --どの属性が多いか判定
    local elementCount = 0
    local targetElement = 0
    local count = 0
    local elementNumBox = {}
    for i = 1,5 do
        elementNumBox[i] = false
    end
    --光・闇は同一属性として扱う
    self.elementBox[4] = self.elementBox[4] + self.elementBox[5]
    self.elementBox[5] = 0  --光で管理
    for i = 1,5 do
        if self.elementBox[i] >= 1 then  --属性種の数を出す
            elementCount = elementCount + 1
            elementNumBox[i] = true
        end
        
        if self.elementBox[i] > count then
            count = self.elementBox[i]
            targetElement = i
        end
    end
    --4体2属性 or 4属性編成だった場合
    if unitNum == 4 then
        --水・光・闇属性が多いか判定
        local aquaType = self.elementBox[2] + self.elementBox[4]
        if aquaType >= 3 then
            return 2
        end

        if elementCount == 2 then
            --3属性(炎水樹)判定
            local targetElementNum = 0
            local count = 0
            for i = 1,5 do
                if elementNumBox[i] then
                    if i == 1 or i == 2 or i == 3 then
                        targetElementNum = i
                        count = count + 1
                    end
                end
            end
            --3属性(炎水樹)2種類か判定
            if count == 1 then
                for i = 0,6 do
                    local myTeamUnit = targetTeam:getTeamUnit(i,true)
                    if myTeamUnit ~= nil then
                        if myTeamUnit:getElementType() == targetElementNum then
                            targetElement = myTeamUnit:getElementType()
                            return targetElement
                        end
                    end
                end
            elseif count == 2 then
                for i = 0,6 do
                    local myTeamUnit = targetTeam:getTeamUnit(i,true)
                    if myTeamUnit ~= nil then
                        targetElement = myTeamUnit:getElementType()
                        return targetElement
                    end
                end
            end
        elseif elementCount == 3 then
        elseif elementCount == 4 then
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    targetElement = myTeamUnit:getElementType()
                    return targetElement
                end
            end
        end
    end

    if unitNum == 3 then
        if elementCount == 3 then
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    targetElement = myTeamUnit:getElementType()
                    return targetElement
                end
            end
        end
    end

    if unitNum == 2 then
        if elementCount == 2 then
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    targetElement = myTeamUnit:getElementType()
                    return targetElement
                end
            end
        end
    end
    return targetElement
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    if not self.changeFlg and self.mode ~= 2 then
        self.battleTime = self.battleTime + event.deltaTime
        if self.battleTime >= self.changeTime then
            self.isChange = true
            self.attack5Flg = true
        end
    end

    --attack7 addSP対策
    if event.unit:getUnitState() ~= kUnitState_attack and self.addSpFlg then
        self.addSpFlg = false
        self:addSP(event.unit)
    end

    --モーション中か確認
    if event.unit:getUnitState() == kUnitState_attack and self.changeFlg then
        self.changeFlg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "rage" then return self:change(event.unit) end
    return 1;
end

function class:change(unit)
    --self:initAttackWeight({CHANGED = 100})
    self:initSkillWeight({CHANGED = 100})
    self.mode = 2
    unit:setSetupAnimationName("idle2");
    --self.stunFLG = 0
    --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
    --self:showMessage(self.CHANGE_MESSAGE_LIST)
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

    if event.index == 1 then
        event.unit:setNextAnimationName("attack3")
        event.unit:setNextAnimationEffectName("1-attack3")
    elseif event.index == 2 then
        event.unit:setNextAnimationName("attack5-2")
        event.unit:setNextAnimationEffectName("1-attack5-2")
    elseif event.index == 3 then
        event.unit:setNextAnimationName("attack5-2")
        event.unit:setNextAnimationEffectName("1-attack5-2")
    elseif event.index == 4 then
        event.unit:setNextAnimationName("attack10")
        event.unit:setNextAnimationEffectName("1-attack10")
    elseif event.index == 5 then
        event.unit:setNextAnimationName("attack7")
        event.unit:setNextAnimationEffectName("1-attack7")
    elseif event.index == 6 then
        event.unit:setNextAnimationName("attack8")
        event.unit:setNextAnimationEffectName("1-attack8")
    elseif event.index == 7 then
        event.unit:setNextAnimationName("attack9")
        event.unit:setNextAnimationEffectName("1-attack9")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.isChange then
        self.isChange = false
        attackIndex = 4
    end

    if self.mode == 2 then
        attackIndex =  self:selectAttack()
    end

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

function class:selectAttack()
    --炎
    if self.elementCount == 1 then
        return 6
    --水、光、闇
    elseif self.elementCount == 2 or self.elementCount == 4 or self.elementCount == 5 then
        return 7
    --樹
    elseif self.elementCount == 3 then
        self.addSpFlg = true
        return 5
    end
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

    --if event.index == 2 and self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    if event.index == 3 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
    end

    if event.index == 2 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
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
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---ダメージ軽減ギミック
    --self:damageValueCalc(event,0,0)  --event,buffID,raceType
    if self.changeFlg then
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

function class:damageValueCalc(event,buffID,raceType)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    --攻撃ユニットがデバフ状態だった場合ダメージ補正
    if buffID ~= 0 then
        local buffCheck = enemyUnit:getTeamUnitCondition():findConditionValue(buffID)
        if buffCheck ~= 0 then
            event.value = event.value * self.buffDamageValRate
        end
    end

    --○族以外はダメージ補正
    if raceType ~= 0 then
        if enemyUnit:getRaceType() ~= raceType then
            event.value = event.value * self.raceDamageValRate
        end
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
    --オービット判定
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
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    if self.mode == 2 then
        event.unit:setNextAnimationName("idle2")
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.mode == 2 then
        event.unit:setNextAnimationName("damage2")
    end
    return 1;
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
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

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
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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