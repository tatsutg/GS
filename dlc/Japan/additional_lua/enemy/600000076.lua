local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="マヴロハロス", version=1.3, id=600000076});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50},
        { ATTACK5 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL2 = 100 },
        { SKILL1 = 100 },
        { SKILL3 = 100 },
        { SKILL2 = 100 },
        { SKILL1 = 100 },
        { SKILL2 = 100 },
        { SKILL3 = 100 }
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

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 6000000761,
            BUFF_ID = 93,   -- 暗闇
            VALUE = 95,
            DURATION = 10,
            ICON = 83
        }
    }

    self.DOWN_LIST = {
        [1] = {
            ID = 6000000762,
            BUFF_ID = 13,   -- 攻撃力
            VALUE = -50,
            DURATION = 10,
            ICON = 4
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下・光属性耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "毒状態のとき、被ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒と麻痺 同時付与で討伐ポイント獲得（5回まで）"})
    }

    self.SKILL7_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL7_MESSAGE1 or "与ダメージアップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL7_MESSAGE2 or "暗闇耐性無効"})
    }

    self.SKILL8_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL8_MESSAGE1 or "編成に多い属性のユニットにダメージアップ",COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL8_MESSAGE2 or "無効化バリア解除",COLOR = Color.red})
    }

    self.POINT_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POINT_MESSAGE1 or "30万討伐ポイント獲得！",COLOR = Color.white}),
    }

    self.CRT_MESSAGE = self.TEXT.DOWN_MESSAGE1 or "さんの毒＆麻痺でボスの攻撃力ダウン"

    -- テロップ
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end

function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,3)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.TELOP_SPAN = 30
class.BATTLE_POINT_VALUE = 300000;
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
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

    self.poisonList = {}
    self.paralyzeList = {}
    self.isPoison = false
    self.isParalyze = false
    self.playerName = BattleControl:get():getPlayerName();
    self.breakPlayerName = self:toUnicode(RaidControl:get():getCustomValue("breakPlayer"))
    self.telopTimer = 0
    self.gameUnit:setAttackDelay(5)

    self.isLockOn = false
    self.isFireEnd = true
    self.shotAngle = 0
    self.neckAngle = 0
    self.neckAngleDefault = 321
    self.fireX = 0
    self.fireY = 0

    self.count = 0
    self.totalBreakCount = RaidControl:get():getCustomValue("totalBreakCount")
    if self.totalBreakCount == "" then
        self.totalBreakCount = 0
    else
        self.totalBreakCount = tonumber(self.totalBreakCount)
    end

    self.gameUnit:addSP(40)

    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self.isLockOn = false
    self.isFireEnd = true
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    --if event.spineEvent == "explosion" then self:explosion() end
    return 1
end

--function class:explosion()
--    self.isFireEnd = true
--    self.shot:setPosition(self.fireX,self.fireY)
--end

function class:targetLock()
    self.isLockOn = true
    self.neckAngle = 305
end

function class:fire(unit)
    self.shot = unit:addOrbitSystem("FireShot2",1)
    self.shot:setActiveSkill(1);
    self.shot:setHitCountMax(1);
    --self.shot:setEndAnimationName("explosion")
    -- shot:EnabledFollow = true;

    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("weights_head");
    local yb = unit:getSkeleton():getBoneWorldPositionY("weights_head");
    self.shot:setPosition(x+xb,y+yb);
    -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
    self.shot:setRotation(-self.neckAngle);
    self.shotAngle = self.neckAngle;
    self.shot:setZOrder(unit:getZOrder() -1);
    self.isFireEnd = false
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    --self:checkFire()
    self:telop(event.deltaTime)
    self:checkMyCond(event.unit)
    self:checkOtherCond()
    return 1
end

--function class:checkFire()
--    if not self.isFireEnd then
--        local x = self.shot:getPositionX();
--        local y = self.shot:getPositionY();
--        local xb = self.shot:getSkeleton():getBoneWorldPositionX("DAMAGEAREA");
--        local yb = self.shot:getSkeleton():getBoneWorldPositionY("DAMAGEAREA");
--        self.fireX =x + xb
--        self.fireY =y + yb
--    end
--end


function class:checkOtherCond()
    local breakPlayer = self:toUnicode(RaidControl:get():getCustomValue("breakPlayer"))
    local breakCount = RaidControl:get():getCustomValue("totalBreakCount")
    if breakCount == "" then
        breakCount = 0
    else
       breakCount = tonumber(breakCount)
    end
    if self.totalBreakCount < breakCount then
        self.breakPlayerName = breakPlayer
        self.totalBreakCount = breakCount
        self:showMessage({self:setMessageInfo({MESSAGE = self.breakPlayerName..self.CRT_MESSAGE})})
        self:execAddDownBuff(self.gameUnit,self.DOWN_LIST[1])
    end
end

function class:checkMyCond(unit)
    self:checkCondition(unit)
    if self.isPoison and self.isParalyze then
        local breakCount = RaidControl:get():getCustomValue("totalBreakCount") == "" and 0 or RaidControl:get():getCustomValue("totalBreakCount")
        self.totalBreakCount = breakCount + 1
        self.count = self.count + 1
        local byteCode = self:toByteCode(self.playerName);
        self.isPoison = false
        self.isParalyze = false
        self.breakPlayerName = self.playerName

        self:execAddDownBuff(self.gameUnit,self.DOWN_LIST[1])
        self:showMessage({self:setMessageInfo({MESSAGE = self.playerName..self.CRT_MESSAGE})})
        RaidControl:get():setCustomValue("breakPlayer",byteCode)
        RaidControl:get():setCustomValue("totalBreakCount",self.totalBreakCount)
        if self.count <= 5 then
            self:showMessage(self.POINT_MESSAGE_LIST)
            RaidControl:get():addBattlePoint(self.BATTLE_POINT_VALUE,0);
        end
    end
end

function class:checkCondition(unit)
    local poisonCount = 0
    local paralyzeCount = 0
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return false end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getConditionTypeAsInt() == 90 then
                if self.poisonList[cond:getID()] == nil or self.poisonList[cond:getID()].TIME < cond:getTime() then
                    self.isPoison = true
                end
                table.insert(self.poisonList,cond:getID(),{ID = cond:getID(),TIME = cond:getTime()})
                poisonCount = poisonCount + 1
            end
            if cond:getConditionTypeAsInt() == 91 then
                if self.paralyzeList[cond:getID()] == nil or self.paralyzeList[cond:getID()].TIME < cond:getTime() then
                    self.isParalyze = true
                end
                table.insert(self.paralyzeList,cond:getID(),{ID = cond:getID(),TIME = cond:getTime()})
                paralyzeCount = paralyzeCount + 1
            end
        end
    end

    if poisonCount == 0 then self.isPoison = false end
    if paralyzeCount == 0 then self.isParalyze = false end
    if self.isPoison and self.isParalyze then
        return true
    end

    return false
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.isSkill3 then
        local val = self:checkElement(event.enemy)
        return val >= 1 and event.value * val or event.value
    end
    return event.value
end

function class:checkElement(unit)
    local count = 0
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if localUnit ~= nil and unit:getElementType() == localUnit:getElementType() then
            count = count + 1
        end
    end
    return count
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.isSkill3 = false
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
    self.isSkill3 = false
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index == 2 then
        --self:showMessage(self.SKILL7_MESSAGE_LIST)
        for i = 0,3 do
            local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if localUnit ~= nil then
                self:execAddBuff(localUnit,self.BUFF_BOX_LIST[1])
            end
        end
    end

    if event.index == 3 then
        self:showMessage(self.SKILL8_MESSAGE_LIST)
        self.isSkill3 = true
    end
    -- 【MEGA_D-9763】ボスの技の予告に、attackDamageValue の相手ごとの倍率（技 3 は、相手と同じ属性の味方の数。1 以上のとき）を入れる（表示専用。古いアプリには無いので確かめてから呼ぶ）
    if self.isSkill3 and event.unit.announceSkillRate then for i = 0, 3 do local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i); if u ~= nil then local n = self:checkElement(u); if n >= 1 then event.unit:announceSkillRate(n, u) end end end end
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
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

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive
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

function class:execAddDownBuff(unit,buff)
    local cond =  unit:getTeamUnitCondition():findConditionWithID(buff.ID)
    if cond ~= nil and cond:getTime() > 0 then
        cond:setTime(cond:getTime() > 10 and 20 or cond:getTime() + 10)
        return
    end
    unit:getTeamUnitCondition():addCondition(buff.ID,buff.BUFF_ID,buff.VALUE,buff.DURATION,buff.ICON);
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

function class:toByteCode(str)
    local result = "";
    for i=1, string.len(str) do
        result = result.." "..str:byte(i);
    end
    return result;
end

function class:toUnicode(str)
    local result = "";
    for i in str:gmatch("%d+") do

        local code = tonumber(i);
        local tmp = str.char(code);
        result = result..tmp;
    end
    return result;
end

class:publish();

return class;