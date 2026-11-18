local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山ウィラカーズ", version=1.3, id="mine_5014"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 , ATTACK2 = 50 },
        { ATTACK4 = 50 },
        { ATTACK2 = 50 , ATTACK3 = 50 },
        { ATTACK4 = 50 },
        { ATTACK3 = 50 , ATTACK1 = 50 },
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL1 = 50 },
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
    SKILL4 = 4
}

function class:setBuffBoxList()
    self.TIMEUP_BUFF_BOX_LIST = {
        [1] = {
            ID = 500141,
            BUFF_ID = 17,      --ダメージ
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 500142,
            BUFF_ID = 13,      --攻撃力
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 3
        }
    }
    self.FLOOR_BUFF_BOX_LIST = {
        [1] = {
            ID = 500143,
            BUFF_ID = 17,      --与ダメージ
            VALUE = 0,
            DURATION = 9999,
            ICON = 26
        }
    }
    self.TIMER_BUFF_BOX_LIST = {
        [1] = {
            ID = 500144,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 4,
            ICON = 0
        }
    }
    self.HP30_BUFF_LIST = {
        [1] = {
            ID = 500145,
            BUFF_ID = 17, --与ダメージ割合
            VALUE = 50,
            DURATION = 999999,
            ICON = 26
        },
        [2] = {
            ID = 500146,
            BUFF_ID = 22, --クリティカル率
            VALUE = 100,
            DURATION = 999999,
            ICON = 11
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
        [1] = self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE1 or "暗闇ユニットに対してダメージアップ" }),
        [2] = self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE2 or "毒ユニットのダメージアップ" }),
        [3] = self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE3 or "反射・奥義ゲージ低下耐性" }),
        [4] = self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE4 or "状態異常耐性無視攻撃" })
    }

    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({ MESSAGE = self.TEXT.HP30_MESSAGE1 or "与ダメージ・クリティカル率アップ" }),
        [2] = self:setMessageInfo({ MESSAGE = self.TEXT.HP30_MESSAGE2 or "奥義使用時奥義ゲージアップ" })
    }

    self.TIMEUP_BUFF_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
    }

end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TIME_UP_ID = 2
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            STOP_BORDER = self.gameUnit:getCalcHPMAX() * 0.3
        },
        [self.TIME_UP_ID] = {
            tag = "TIME_UP",
            action = function (status) self:timeUp(status) end,
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

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
    end
end


function class:hp30(status)
    if status == "use3" then
        self.isRage = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(6)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_LIST[2])
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
    self.skillCheckFlg2 = false;
    self.attack2FLG = false
    self.addSP20FLG = false
    self.addSP20 = false
    self.addSP_Timer = false
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()
    --現在階層を取得する関数
    --鉱山バトルでないとエラーが出る
    local floor = megast.Battle:getInstance():getCurrentMineFloor();

    --テロップ用変数
    self.telopSpan = 60
    self.showMessageTimer = 0

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)
    self:floorPowerUp()

    self.flgTimer = 0
    return 1
end

--10階層ごとにダメージUP
function class:floorPowerUp()
    local floor = megast.Battle:getInstance():getCurrentMineFloor()
    if floor <= 25 then
        self.FLOOR_BUFF_BOX_LIST[1].VALUE = 0
    else
        local floorFixed = floor -26
        self.FLOOR_BUFF_BOX_LIST[1].VALUE = floorFixed - (floorFixed % 10)
    end

    if self.FLOOR_BUFF_BOX_LIST[1].VALUE == 0 then
        self.FLOOR_BUFF_BOX_LIST[1].ICON = 0
    end
end

----// startWave //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.FLOOR_BUFF_BOX_LIST[1])
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:HPTriggersCheck(event.unit)

    if self.addSP_Timer then
        if event.unit:getTeamUnitCondition():findConditionWithID(500144) == nil then
            self.addSP_Timer = false
            self:addSP(event.unit);
        end
    end

    if self.addSP20 then
        self:addSP(event.unit);
        self.addSP20 = false;
    end

    self:checkFlg(event.deltaTime)
    self:setTimeUp()
    self:telopCheck(event.deltaTime)
    return 1
end

function class:setTimeUp()
    if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TIME_UP_ID].used then
        self:execTrigger(self.TIME_UP_ID)
    end
end

-- 一定時間ごとに戦闘開始時メッセージを流す
function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
        self.showMessageTimer = 0
        self:showMessage(self.START_MESSAGE_LIST)
    else
        self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

function class:checkFlg(deltaTime)
    if self.isFlg and not self.TRIGGERS[1].used then
        if self.flgTimer < 5 then
            self.flgTimer = self.flgTimer + deltaTime
        else
            self.isFlg = false
            self:execTrigger(1)
            self.TRIGGERS[1].used = true
        end
    end
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


    if event.index == 4 then
        event.unit:setNextAnimationName("skill4")
        event.unit:setNextAnimationEffectName("1-skill4")
        event.unit:setActiveSkill(4)
        self.addSP_Timer = true
        self:execAddBuff(event.unit,self.TIMER_BUFF_BOX_LIST[1])
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
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

    if event.index == 2 then
        self.gameUnit:setInvincibleTime(3)
    end
    if self.addSP20FLG then
        self.addSP20 = true
    end
    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    if self.isRage then
        skillIndex = 2
        self.isRage = false
        self.addSP20FLG = true
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
-- 毒状態のユニットのボスに対するダメージUP
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isRage then
        event.value = 0
    end
    if event.enemy:getParentTeamUnit() == nil then
        if event.enemy:getTeamUnitCondition():findConditionWithType(90) ~= nil then
            event.value = event.value * 1.3
        end
    else
        if event.enemy:getParentTeamUnit():getTeamUnitCondition():findConditionWithType(90) ~= nil then
            event.value = event.value * 1.3
        end
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value

    for _,trigger in pairs(self.HP_TRIGGERS) do
        if not trigger.used and trigger.STOP_BORDER > anotherHp then
            self.isFlg = true
            return unit:getHP() < trigger.STOP_BORDER and 1 or self:calcDamageValue(unit,trigger.STOP_BORDER,value)
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
    if self.isRage then
        event.value = 0
    end
    return event.value
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
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
    self.TRIGGERS[args.arg].used = true
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


--[[
  どの攻撃パターンを使うか決めています。
  initAttackWeight({DEFAULT = 100})なら100の確率でDEFAULTを使用、
  initAttackWeight({HP50 = 100})なら100の確率でHP50を使用、
  initAttackWeight({DEFAULT = 30,HP50 = 70})なら30の確率でDEFAULTを使用、70の確率でHP50を使用します。
]]
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

class:publish();

return class;