local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="賢凰の神殿／フォンギオン", version=1.3, id=4001600});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK4=50},
        {ATTACK1=50, ATTACK2=50},
        {ATTACK1=50, ATTACK3=50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    },
    HP50 = {
        { SKILL3 = 50 }
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
    SKILL4 = 6,
    SKILL5 = 7
}

class.cutInSkill = {
    [1] = 1,
    [4] = 1,
    [5] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 23,---クリティカル耐性
            VALUE = -100,
            DURATION = 99999,
            ICON = 188
        },
        [2] = {
            ID = 40016003,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end ---オーラ
        },
        [3] = {
            ID = 5041120,
            BUFF_ID = 17,---与ダメージ
            VALUE = 25,
            DURATION = 99999,
            ICON = 26,
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
    self.BREAK_GUARD_BUFF_LIST = {
        ID = 4001600,
        BUFF_ID = 239,
        VALUE = 0.1,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "人族からのダメージを軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "神族からのブレイクを軽減", COLOR = Color.yellow})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "鉄壁：ブレイクで解除", COLOR = Color.red})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！鉄壁状態を解除！", COLOR = Color.red})
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
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.breakFLG = true
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.spValue = 40;---addSPの量
        self.hpSkill = 1
        self.saveBP = 0
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * 0.3)
        self:showMessage(self.HP0_MESSAGE_LIST)
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

    self.breakFLG = false

    ---フォンギオンで使用する変数たち
    self.stopOrbit = nil;
    self.isStop = false;
    self.reverceMode = false;
    self.hitStopRegection = true;
    self.forceSkillNumber = 0;
    self.isReady = false
    self.Clock = nil;
    self:createClock(event.unit);

    self:execAddBuff(event.unit,self.BREAK_GUARD_BUFF_LIST)
    self.endLessFLG = false
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
    ---ブレイク値減少対象にフラグバフを付与
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BREAK_GUARD_BUFF_LIST.ID)
            if myTeamUnit:getRaceType() == 7 and cond == nil then
                self:execAddBuff(myTeamUnit,self.BREAK_GUARD_BUFF_LIST)
            end
        end
    end
    if self.TRIGGERS[3].used then
        if not self.endLessFLG then
            local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID)
            if buff == nil then
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
            end
        else
            local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID)
            if buff ~= nil then
                event.unit:getTeamUnitCondition():removeCondition(buff);
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
        --event.unit:setBreakPoint(event.unit:getBaseBreakCapacity());
        self.Clock:setVector(1);
    end

    if event.spineEvent == "reverceEnd" then
        self.Clock:setVector(1);
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
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        self:stunRemove(event.unit)
        self.endLessFLG = false
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

    if event.index == 4 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2")
    elseif event.index == 5 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3")
    end

    self.lastSkillFLG = true

    if event.index == 1 or event.index == 3 or event.index == 5 then
        self:stun(event.unit)
    end

    if event.index == 3 or event.index == 5 then
        self.endLessFLG = true
    end

    if event.index == 2 or event.index == 3 or event.index == 4 or event.index == 5 then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    end

    if event.index == 1 then
        local buff = event.unit:getTeamUnitCondition():addCondition(40016002,0,0,99999,0)
        buff:setRemoveOnResetState(true);
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
            myTeamUnit:getTeamUnitCondition():addCondition(40016001,89,100,30,79);
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
    return 1
end

function class:stunRemove(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:getTeamUnitCondition():addCondition(40016001,0,0,0,0);
        end
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(40016002)
    if self.TRIGGERS[3].used and buff == nil then
        return 1
    else
        return 0
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.enemy:getRaceType() == 1 then
        event.value = event.value * 0.4
    end
    if self.breakFLG then
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

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    local checkUnit = event.enemy
    if event.enemy:getParentTeamUnit() ~= nil then
        checkUnit = event.enemy:getParentTeamUnit()
    end
    if checkUnit:getRaceType() == 7 then
        event.value = event.value * 0.1
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
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    if self.breakFLG then
        self.breakFLG = false
        self:initSkillWeight({HP50 = 100})
        self:showMessage(self.BREAK_MESSAGE_LIST)
    end
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
            uni:getTeamUnitCondition():addCondition(-12,92,100,10,0);
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

class:publish();

return class;