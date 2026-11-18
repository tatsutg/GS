local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="チャレンジQマールゼクス", version=1.3, id=2029556});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50}
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
    SKILL3 = 7,
    SKILL4 = 8
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP50_BUFF_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージ無効化キラー"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "奥義中被ダメージ軽減"})
    }
    self.SKILL8_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL8_MESSAGE1 or "奥義増加速度アップ"})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
    }
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
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

    self.BreakDamageCount = 0

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self.hpMarkers = {}

    self.isFirst = true
    self.idleFLG = false
    self.mode = 1
    self.idleFLG = false
    self.countAddSpTime = 0
    self.addSpTime = 1.6
    self.modeChangeFLG = 0

    self.TIME_LIMIT = 360
    self.countTimer = 0
    self.battleEnd = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)
    event.unit:setAttackDelay(1)

    self.stateName = "NORMAL"
    return 1
end

function class:startWave(event)
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png",self.TIME_LIMIT ,30, 620 , -100 ,0.8);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)
    if self.idleFLG then
        self.countAddSpTime = self.countAddSpTime + event.deltaTime
        if self.countAddSpTime > self.addSpTime then
            self.countAddSpTime = 0
            self:addSP(event.unit)
        end
    end
    self.countTimer = self.countTimer + event.deltaTime
    if self.countTimer > self.TIME_LIMIT then
        self.battleEnd = true
    end
    if event.unit:getUnitState() == 7 and self.skillFLG and self.gameUnit:getBurstPoint() == 0 then
        event.unit:takeIdle()
    end
    return 1
end

----// attackDamageValue //-----------------------------------------------------------------------------
-- 条件 : 本体の攻撃Hit時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃対象  event.value / 与ダメージ量
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.battleEnd then
        event.value = 999999
    end
    return event.value
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "askNext" then
        self:appear(event.unit);
    end

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

function class:appear(unit)
    local animName = "tpAppear"..(self.mode);
    unit:takeAnimation(0,animName,false);
    unit:takeAnimationEffect(0,"tpAppear",false);
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
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    if self.isFirst then
        self.isFirst = false
        self.idleFLG = false
        self:modeChange()
        event.unit:setAttackDelay(10)
        return 1
    end
    event.unit:takeIdle();
    return 0
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    --[[--下記コード使用で行動前に奥義ゲージが上がるユニットでも行動パターンを崩さず奥義を撃てる(必要に応じて改造)
    if self.gameUnit:getBurstPoint() ~= 80 then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    ]]--
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
    self.idleFLG = false
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 4 then
        self.addSpTime = self.addSpTime * 9/10
        self.gameUnit:setInvincibleTime(20)
    end
    self.modeChangeFLG = true
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self.skillFLG = true
    self:skillActiveSkillSetter(event.unit,event.index);
    self:modeChange()
    if event.index == 4 then
        self.modeChangeFLG = -1
    end
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    --skillIndex = self.mode
    if self.mode == 1 then
        skillIndex = 4
    else
        skillIndex = self.mode - 1
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeIdle //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeIdle(event)
    self.idleFLG = true
    if self.modeChangeFLG == -1 then
        self.modeChangeFLG = 1
        self:showMessage(self.SKILL8_MESSAGE_LIST)
    end
    if self.modeChangeFLG == 1 then
        self.modeChangeFLG = 2
        if self.mode == 2 then
            event.unit:takeAnimation(0,"weaponAppearSword",false);
            event.unit:setUnitState(kUnitState_idle);
            event.unit:setSetupAnimationName("setUpSword");
            event.unit:takeAnimationEffect(0,"weaponAppearSword",false);
            return 0
        elseif self.mode == 3 then
            event.unit:takeAnimation(0,"weaponAppearSpear",false);
            event.unit:setUnitState(kUnitState_idle);
            event.unit:setSetupAnimationName("setUpSpear");
            event.unit:takeAnimationEffect(0,"weaponAppearSpear",false);
            return 0
        elseif self.mode == 4 then
            event.unit:takeAnimation(0,"weaponAppearBow",false);
            event.unit:setUnitState(kUnitState_idle);
            event.unit:setSetupAnimationName("setUpBow");
            event.unit:takeAnimationEffect(0,"weaponAppearBow",false);
            return 0
        else
            event.unit:setSetupAnimationName("setUpNormal");
            self.modeChangeFLG = 0
        end
    end
    if self.modeChangeFLG == 2 then
        self.modeChangeFLG = 0
        if self.mode > 1 then
            event.unit:takeAnimation(0,"tpAppear"..self.mode,false);
            event.unit:setUnitState(kUnitState_idle);
            event.unit:takeAnimationEffect(0,"tpAppear"..self.mode,false);
            return 0
        end
    end
    self.gameUnit:setInvincibleTime(0)
    self.skillFLG = false
    return 1;
end

function class:modeChange()
    self.modeChangeFLG = 1
    if self.mode == 4 then
        self.mode = 1
    else
        self.mode = self.mode + 1
    end
end
----// takeBack //-----------------------------------------------------------------------------

---------------------------------------------------------------------------------
function class:takeBack(event)
    self.idleFLG = false
    return 1;
end

----// takeDamage //-----------------------------------------------------------------------------
-- 条件 : ひるみ時。攻撃を受けた時ではない。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self.idleFLG = false
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.skillFLG then
        event.value = event.value * 0.3
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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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
    for i,value in ipairs({89,91,96}) do
        local condition = unit:getTeamUnitCondition():findConditionWithType(value)
        if condition ~= nil then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
    end
end

class:publish();

return class;