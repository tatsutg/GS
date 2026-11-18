local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EXグロイツ", version=1.3, id=1505024});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK3 = 50},
        { ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 ,SKILL2 = 50}
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


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 501771313,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 10,
        ICON = 79
    }
    self.HEAL_BUFF_LIST = {
        ID = 501771313,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
    self.DELAY_HEAL_BUFF_LIST = {
        ID = 501771313,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 4,
        ICON = 79
    }
    self.ATTACK_DOWN_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 13,
        VALUE = -30,
        DURATION = 99999,
        ICON = 4
    }
    self.DEFENCE_DOWN_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 15,
        VALUE = -30,
        DURATION = 99999,
        ICON = 6
    }
    self.ATTACK_UP_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 17,
        VALUE = 30,
        DURATION = 99999,
        ICON = 26
    }
    self.TAKE_CRITICAL_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 23,
        VALUE = -200,
        DURATION = 99999,
        ICON = 188
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST = {
        ID = 20336541,
        BUFF_ID = 113, ---状態異常耐性(状態異常回避率)
        VALUE = 999999,
        DURATION = 999999,
        ICON = 67
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST2 = {
        ID = 20336541,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 0,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "樹属性からの被ダメージアップ",
                             COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒状態のユニットの被ダメージアップ",
                             COLOR = Color.green})
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
        self.saveBP = self.gameUnit:getBurstPoint()
        self.isRage = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
        self:removeAllBadstatus(self.gameUnit) ---状態異常全除去
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)
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
    --event.unit:setAttackDelay(5);---アタックディレイ
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

    self.saveBP = 0

    self.stopCheckFLG = false

    ---グロイツ関連
    self.holdFLG = false
    self.targetList ={}
    for i = 0, 6 do self.targetList[i] = false end
    self.BPList ={}
    for i = 0, 6 do self.BPList[i] = 0 end
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
    ---グロイツ関連
    if self.holdFLG then
        ---掴み中
        self:holdKeep(event.unit)
    end
    if not self.stopCheckFLG then
        if megast.Battle:getInstance():isHost() then
            ---ホストのみターゲットチェック
            self:checkTarget()
        end
    end
    ---
    return 1
end

function class:holdKeep(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("HOOK");
    local yb = unit:getSkeleton():getBoneWorldPositionY("HOOK");
    for i = 0, 6 do
        if self.targetList[i] then
            local myTeamUnit = myTeam:getTeamUnit(i)
            myTeamUnit:setPosition((x + (xb/2) + (5*i)),(y + yb + (5*i)))
        end
    end
    return 1
end

function class:checkTarget()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local BP = 0
    ---奥義ゲージの最大値を求める
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.BPList[i] = myTeamUnit:getBurstPoint()
            if myTeamUnit:getBurstPoint() >= BP then
                BP = myTeamUnit:getBurstPoint()
            end
        end
    end
    ---奥義ゲージの最大値を持つユニット全員をターゲットに
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.BPList[i] >= BP then
                self.targetList[i] = true
                megast.Battle:getInstance():sendEventToLua(self.scriptID,5,i)
            else
                self.targetList[i] = false
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,i)
            end
        end
    end
end

function class:receive5(args)
    self.targetList[args.arg] = true
    return 1
end

function class:receive6(args)
    self.targetList[args.arg] = false
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    ---掴み準備
    if event.spineEvent == "stun" then return self:stun(event.unit) end
    ---掴み開始
    if event.spineEvent == "holdStart" then return self:holdStart(event.unit) end
    ---毒注入
    if event.spineEvent == "first" then return self:first(event.unit) end
    if event.spineEvent == "second" then return self:second(event.unit) end
    if event.spineEvent == "third" then return self:third(event.unit) end
    ---掴み終わり
    if event.spineEvent == "holdEnd" then return self:holdEnd(event.unit) end
    return 1;
end

function class:stun(unit)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("HOOK");
    local yb = unit:getSkeleton():getBoneWorldPositionY("HOOK");
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_LIST)
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
    return 1
end

function class:holdStart(unit)
    self.holdFLG = true
    self.stopCheckFLG = true
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if not self.targetList[i] then
                self:execAddBuff(myTeamUnit,self.HEAL_BUFF_LIST)
                myTeamUnit:setInvincibleTime(1)
            end
        end
    end
    return 1
end

function class:first(unit)
    self:damage10(1)
    return 1
end

function class:second(unit)
    self:damage10(2)
    return 1
end

function class:third(unit)
    self:damage10(3)
    return 1
end

function class:damage10(phase)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.targetList[i] then
                local damage = myTeamUnit:getCalcHPMAX() /10
                local hp = myTeamUnit:getHP() - damage
                if hp < 0 then hp = 0 end
                local artsHpBefore = myTeamUnit:getHP()
                myTeamUnit:setHP(hp)
                -- 【MEGA_D-9756】メッセージログで、この技の行に減った HP を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
                if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
                    megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, myTeamUnit, artsHpBefore - myTeamUnit:getHP())
                end
                self:execAddBuff(myTeamUnit,self.DELAY_HEAL_BUFF_LIST)
            end
        end
    end
end

function class:holdEnd(unit)
    self.holdFLG = false
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setInvincibleTime(0)
            if self.targetList[i] then
                self:execAddBuff(myTeamUnit,self.HEAL_BUFF_LIST)
            end
        end
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
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.stopCheckFLG = false
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST2)
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

    if event.index == 3 and self.isRage then
        self.isRage = false
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
        skillIndex = 3
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

function class:findBadCondition(unit)
    local cnt = 0;
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

function class:isRaceTypeX(unit,x)
    if unit:getRaceType() == x then
        return true;
    end
    if unit:getParentTeamUnit() ~= nil then
        if unit:getParentTeamUnit():getRaceType() == x then
            return true;
        end
    end
    return false;
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
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self.gameUnit:setInvincibleTime(0)
    self.stopCheckFLG = false
    return 1;
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