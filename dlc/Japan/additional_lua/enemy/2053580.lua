local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX極_クオ・ヴァディス(白亜の巨神)", version=1.3, id=2053580});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 }
    },
    HP40 = {
        { ATTACK4 = 50 }
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
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 20535801,
            BUFF_ID = 13,  --攻撃力UP
            VALUE = 60,
            DURATION = 99999,
            ICON = 3
        },
        [2] = {
            ID = 20535802,
            BUFF_ID = 23,   --クリティカル耐性DOWN
            VALUE = 50,
            DURATION = 99999,
            ICON = 13
        },
        [3] = {
            ID = 20535801,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0
        },
        [4] = {
            ID = 20535802,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20535803,
            BUFF_ID = 13,  --攻撃力UP
            VALUE = 120,
            DURATION = 30,
            ICON = 3
        },
        [2] = {
            ID = 20535803,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・クリティカル耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "魔族からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒状態の時、攻撃力・被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP1_MESSAGE1 or "13秒間毒以外のダメージを無効", COLOR = Color.red})
    }
    self.DEBUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_MESSAGE1 or "攻撃力・被ダメージアップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_MESSAGE2 or "クリティカル耐性ダウン", COLOR = Color.red})
    }
    self.DEBUFF_CLEAR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CLEAR_MESSAGE1 or "攻撃力・被ダメージダウン", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CLEAR_MESSAGE2 or "クリティカル耐性アップ", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp1(status) end,
            HP = 1,
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

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.gameUnit:addSP(100)
        self.hpSkill = 2
        self:initAttackWeight({HP40 = 100})
    end
end

function class:hp1(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.hpFlg = true
        self:showMessage(self.HP1_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 10;---addSPの量
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

    ---ボスギミック
    self.hpSkillFlg = false
    self.hpFlg = false
    self.battleTime = 0
    self.lastHpTime = 13
    self.debuffFlg = false
    self.debuffMsgFlg = 0
    self.buffIDList = {90}

    --白亜の巨神で使用するやつ
    self.unitIndexList = {}
    self.unitIndexList = self:searchUnitList()
    return 1
end

--白亜の巨神で使用するやつ
------------------------------------------------------------
function class:searchUnitList()
    local lst = {}
    for i = 0,3 do
        local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if teamUnit ~= nil then
            table.insert(lst,teamUnit:getIndex())
        end
    end
    return lst
end
------------------------------------------------------------

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --デバフギミック
    self:checkDebuff(event.unit)
    if self.debuffFlg then
        if self.debuffMsgFlg == 0 then
            self.debuffMsgFlg = 1
        end

        if self.hpSkillFlg then
            self:execAddBuff(event.unit,self.BUFF_LIST[3])
        end
        --HP1ギミック
        if self.hpFlg then
            event.unit:setHP(0)
        end
    end

    if self.hpSkillFlg then
        --奥義中か確認
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.hpSkillFlg = false
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2])
            self:execAddBuff(event.unit,self.BUFF_LIST[4])
        elseif event.unit:getUnitState() == kUnitState_skill and not self.debuffFlg then
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2])
            self:execAddBuff(event.unit,self.BUFF_LIST[4])
        elseif event.unit:getUnitState() == kUnitState_skill and self.debuffFlg then
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1])
            self:execAddBuff(event.unit,self.BUFF_LIST[2])
        end
    else
        if self.debuffFlg then
            self:execAddBuff(event.unit,self.BUFF_LIST[1])
            self:execAddBuff(event.unit,self.BUFF_LIST[2])
        else
            self:execAddBuff(event.unit,self.BUFF_LIST[3])
            self:execAddBuff(event.unit,self.BUFF_LIST[4])
        end
    end

    if self.debuffMsgFlg == 1 and self.debuffFlg then
        self.debuffMsgFlg = 2
        self:showMessage(self.DEBUFF_MESSAGE_LIST)
    elseif self.debuffMsgFlg == 2 and not self.debuffFlg then
        self.debuffMsgFlg = 0
        self:showMessage(self.DEBUFF_CLEAR_MESSAGE_LIST)
    end

    --HP1ギミック
    if self.hpFlg then
        self.battleTime = self.battleTime + event.deltaTime
        if self.battleTime >= self.lastHpTime then
            self.hpFlg = false
        end
    end

    --白亜の巨神で使用するやつ
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:setPosition(event.unit)
    end
    self:checkUnitPosition(self.unitIndexList)
    return 1
end

function class:checkDebuff(unit)
    self.debuffFlg = false
    for k,v in ipairs(self.buffIDList) do
        local teamUnit = unit:getTeamUnitCondition():findConditionWithType(self.buffIDList[k])
        if teamUnit ~= nil then
            self.debuffFlg = true
            break
        end
    end
end

--白亜の巨神で使用するやつ
------------------------------------------------------------
function class:setPosition(unit)
    unit:setZOrder(1)
    unit:setPositionX(-20);
    unit:setPositionY(-30);
    unit:getSkeleton():setPosition(0,0);
end

function class:checkUnitPosition(unitList)
    for _,v in pairs(unitList) do
        local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(v)
        if teamUnit ~= nil then
            if teamUnit:getAnimationPositionX() < 35 then
                teamUnit:setPositionX(teamUnit:getPositionX() - (teamUnit:getAnimationPositionX() - 35));
            end
        end
    end
end
------------------------------------------------------------

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
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

    --if event.index == 2 and self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    --if event.index == 3 then
    --    event.unit:setNextAnimationName("skill1-1")
    --    event.unit:setNextAnimationEffectName("1-skill1")
    --end

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
    elseif event.index == 2 then
        self.hpSkillFlg = true
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

    if not self.debuffFlg then
        event.value = event.value * 0.3
    elseif self.debuffFlg and self.hpSkillFlg then
        event.value = event.value * 3
    elseif self.debuffFlg then
        event.value = event.value * 1.5
    end

    if self.hpFlg then
        return 0
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