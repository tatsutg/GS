local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="虹天景_封神域4_オージュ闇（第二形態）", version=1.3, id=5041416});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK5 = 50 },
        { ATTACK3 = 50, ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK3 = 50 }
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
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 21,  --被ダメージアップ
            VALUE = 20,
            DURATION = 9999999,
            ICON = 139
        },
        [2] = {
            ID = 504141601,
            BUFF_ID = 23,  --クリティカル耐性UP
            VALUE = -200,
            DURATION = 9999999,
            ICON = 188
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "パーティーの属性数が多いほど、ボスの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイク中、被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "イヴィル・エッジ：ダメージ無効化無効", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "イヴィル・エッジ：ダメージ無効化無効", COLOR = Color.yellow})
    }
    self.BREAK_HEAL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_HEAL_MESSAGE1 or "属性からのブレイクダメージを軽減", COLOR = Color.yellow})
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
            HP = 0.001,
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
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.cutInFLG = true
        self.gameUnit:setInvincibleTime(14)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])  --クリティカル耐性UP
        self.gameUnit:setAttackDelay(8);---アタックディレイ
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        --self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.cutInFLG = true
        self:showMessage(self.HP0_MESSAGE_LIST)
        self.gameUnit:setInvincibleTime(14)
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
    event.unit:setAttackDelay(10);---アタックディレイ
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

    self.breakFlg = false
    self.targetElements = {}
    self.breakDamageRate = 0.2
    self.skill1BuffRate = -20
    self.breakDamageTbl = {}
    self.elementBuffIconTbl = {[1]=38,
                               [2]=39,
                               [3]=40,
                               [4]=41,
                               [5]=42,
    }
    self.elementValueTbl = {[1]="火",
                            [2]="水",
                            [3]="樹",
                            [4]="光",
                            [5]="闇",
    }

    self.elementCount = 0
    self.damageBox = {
        [4] = 1,
        [3] = 0.5,
        [2] = 0.2,
        [1] = 0.1
    }

    --オージュ（第二形態）
    --local bossfire = BattleControl:get():addAnimation("FIRE","FIRE3",true);
    --bossfire:setPositionX(-450);
    --bossfire:setPositionY(-30);
    --bossfire:setZOrder(30000);
    --bossfire:setScale(1.2);
    return 1
end

function class:enemyElementCount(unit)
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
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.elementBox = {}
    for i = 1,5 do
        self.elementBox[i] = false
    end
    self.elementCount = self:enemyElementCount(event.unit)
    return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --ブレイク復帰時
    if event.unit.m_breaktime <= 0 and self.breakFlg then
        self.breakFlg = false
        self:breakHeal(event.unit)
    end

    --HP0ギミック
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.deadFlg and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
        end
        if self.TRIGGERS[2].used then
            event.unit:setInvincibleTime(1)
            if self.deadCount == nil then
                self.deadCount = 0
            end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 14 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
            end
        end
    end

    --オージュ（第二形態）
    event.unit:setDefaultPosition(-400 , -100);
    event.unit:setPositionX(-400);
    event.unit:setPositionY(-100);
    --BattleControl:get():focusCamera(0,0,0,0.72,4,0,1);
    --BattleControl:get():setCameraDefaultScale(0.72);
    return 1
end

function class:breakHeal(unit)
    local breakDamage = 0
    local maxBreakDamage = 0
    local targetElement = nil
    --多くブレイクダメージを与えたユニットの判定
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local enemyUnit = self:getAncestorUnit(myTeamUnit)
            local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
            if self.breakDamageTbl[index] ~= nil then
                breakDamage = self.breakDamageTbl[index].dps
                if maxBreakDamage <= breakDamage then
                    targetElement = myTeamUnit:getElementType()
                    maxBreakDamage = breakDamage
                end
            end
        end
    end

    if not self.targetElements[targetElement] then
        self.targetElements[targetElement] = true
        --属性耐性のバフアイコンのみ付与
        local buffId = 5041416 .. targetElement
        self:buffRefresh(unit, buffId)
        unit:getTeamUnitCondition():addCondition(buffId, 0, 0, 9999999, self.elementBuffIconTbl[targetElement])
        --ブレイク復帰メッセージ
        self.BREAK_HEAL_MESSAGE_LIST = {
            self:setMessageInfo({MESSAGE = self.TEXT.BREAK_HEAL_MESSAGE2 or self.elementValueTbl[targetElement].."属性からのブレイクダメージを軽減",
                                COLOR = Color.yellow})
        }
        self:showMessage(self.BREAK_HEAL_MESSAGE_LIST)
    end

    self.breakDamageTbl = {}
    return 1
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "doubleSaw" then return self:doubleSaw(event.unit) end
    return 1;
end

function class:doubleSaw (unit)
    local saw1 = unit:addOrbitSystemWithFile("skill3_EF","saw1");
    local saw2 = unit:addOrbitSystemWithFile("skill3_EF","saw2");
    saw1:setZOrder(8000);
    saw2:setZOrder(0);
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

    if self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 1 then
        self:skill1Buff()
    elseif event.index == 2 then
        self:skill2Buff()
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

function class:skill1Buff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(504141602)
            local buffCount = 1
            if buff ~= nil then buffCount = buff:getNumber() + 1 end
            if buffCount >= 5 then buffCount = 5 end
            local valueCalc = self.skill1BuffRate * buffCount
            local BUFF_LIST1 = {
                ID = 504141602,
                BUFF_ID = 13,   --攻撃力DOWN
                VALUE = valueCalc,
                DURATION = 9999999,
                ICON = 4,
                COUNT = buffCount,
                MAX = 6
            }
            self:buffRefresh(myTeamUnit,BUFF_LIST1.ID)
            self:execAddBuff(myTeamUnit,BUFF_LIST1)
        end
    end
end

function class:skill2Buff()
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
                        self:execAddBuff(teamUnit,self.BUFF_LIST[1])
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.BUFF_LIST[1])
            end
        end
    end
end

function class:buffRefresh(unit,buffID)
    local badStatusIDs = {buffID};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithID(targetID);
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = event.value * self.damageBox[self.elementCount]
    --ブレイク中以外、受けるダメージ減
    if event.unit.m_breaktime <= 0 then
        event.value = event.value * self.breakDamageRate
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
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    --高ブレイクダメージのユニット属性からのブレイクダメージを軽減
    local unitElement = event.enemy:getElementType()
    if self.targetElements[unitElement] then
        event.value = 1
    end

    --与えられたブレイクダメージを保存
    self:unitBreakeDamage(event.enemy,event.value)
    return event.value
end

function class:unitBreakeDamage(enemy,value)
    local enemyUnit = self:getAncestorUnit(enemy)
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.breakDamageTbl[index] == nil then
        table.insert(self.breakDamageTbl,index,{unit = enemyUnit,dps = value})
    else
        self.breakDamageTbl[index].dps = self.breakDamageTbl[index].dps + value
    end
    --summoner.Utility.messageByEnemy(self.breakDamageTbl[index].dps)
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
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
    self.breakFlg = true
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