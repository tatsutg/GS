local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="狐タマエ", version=1.8, id="mine_5012"})
class:inheritFromUnit("unitBossBase");

--[[
ATTACK1,5 火の玉突進
ATTACK2,6 噴火
ATTACK3,7 剣撃
]]

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    FIRE_1={
        { ATTACK3 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50 }
    },
    DARK_1={
        { ATTACK7 = 100 },
        { ATTACK5 = 50, ATTACK6 = 50 },
        { ATTACK5 = 50, ATTACK7 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    FIRE_1={
        { SKILL4 = 100 }
    },
    DARK_1={
        { SKILL5 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 3,
    ATTACK3 = 1,
    ATTACK4 = 1,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 4,
    SKILL1 = 1,
    SKILL2 = 7,
    SKILL3 = 7,
    SKILL4 = 7,
    SKILL5 = 8
}

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
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false
        },
        [4] = {
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

function class:hp70(status)
    if status ==  "use3" then
        self:showMessage(self.HP70_MESSAGE_LIST)
        self:addBuff(self.gameUnit,self.HP70_BUFF_BOX)
    end
end

function class:hp50(status)
    if status ==  "use3" then
        -- self.gameUnit:setInvincibleTime(6)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:addBuff(self.gameUnit,self.HP50_BUFF_BOX)
    end
end

function class:hp25(status)
    if status ==  "use3" then
        self:showMessage(self.HP25_MESSAGE_LIST)
        self:addBuff(self.gameUnit,self.HP25_BUFF_BOX)
        self.gameUnit:addSP(100)
    end
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST)
    end
end


function class:change()
    if self.isAwaken then self:awaken() else self:normal() end
    self.gameUnit:takeGrayScale(0.01)
    self.isNega = true
    self.negaTimer = 0

    for i = 0,3 do
        local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
            u:takeGrayScale(0.01)
        end
    end
end

function class:awaken()
    self.isAwakened = true
    self.gameUnit:setSkin("rage")
    self:initAttackWeight({DARK_1 = 100})
    self:initSkillWeight({DARK_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,241,35,177);
    megast.Battle:getInstance():setBossCounterElement(5);
    self.gameUnit:setElementType(5);
    self:removeCondition(self.gameUnit,self.FIRE_BUFF_BOX[1].ID)
    self:removeCondition(self.gameUnit,self.FIRE_BUFF_BOX[2].ID)
    self:addBuff(self.gameUnit,self.DARK_BUFF_BOX)
    self:showMessage(self.DARK_MESSAGE_LIST)
end

function class:normal()
    self.isAwakened = false
    self.gameUnit:setSkin("normal")
    self:initAttackWeight({FIRE_1 = 100})
    self:initSkillWeight({FIRE_1 = 100})
    megast.Battle:getInstance():setBackGroundColor(9999,255,255,255);
    megast.Battle:getInstance():setBossCounterElement(1);
    self.gameUnit:setElementType(1);
    self:removeCondition(self.gameUnit,self.DARK_BUFF_BOX[1].ID)
    self:removeCondition(self.gameUnit,self.DARK_BUFF_BOX[2].ID)
    self:addBuff(self.gameUnit,self.FIRE_BUFF_BOX)
    self:showMessage(self.FIRE_MESSAGE_LIST)
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "吾が名を恐れよ、妖狐『憂月』の名を——",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "病気・氷結状態のとき被ダメージアップ"
        })
    }
    self.HP70_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE2 or "満たせ…満たせ…",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "攻撃力アップ"
        })
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "染まれ…染まれ…赫く…冥く",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "与ダメージアップ"
        })
    }
    self.HP25_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP25_MESSAGE2 or "今宵は血月——存分に喰らい尽くそうか",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP25_MESSAGE1 or "クリティカル率アップ"
        })
    }

    self.TIMEUP_BUFF_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.red,
            DURATION = 5,
            isPlayer = false
        },
        [2] = {
            MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",
            COLOR = Color.red,
            DURATION = 5,
            isPlayer = false
        }
    }

    self.FIRE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.FIRE_MESSAGE or "炎属性攻撃無効"
        })
    }
    self.DARK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DARK_MESSAGE or "闇属性攻撃無効"
        })
    }

    self.SICK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SICK_MESSAGE or "くふっ…吾が血を冒す…此れは…？",
            COLOR = Color.magenta
        })
    }

    self.FREEZE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.FREEZE_MESSAGE or "…！ 餌風情が！",
            COLOR = Color.magenta
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE or "月が…視えぬ…何故…",
            COLOR = Color.magenta
        })
    }
end

--------[[バフ]]--------
function class:setBuffBoxList()
    self.HP70_BUFF_BOX = {
        [1] = {
            ID = 5213130,
            BUFF_ID = 13, -- 攻撃
            VALUE = 50,
            DURATION = 999999,
            ICON = 3
        }
    }
    self.HP50_BUFF_BOX = {
        [1] = {
            ID = 5213132,
            BUFF_ID = 17, -- ダメージ
            VALUE = 30,
            DURATION = 999999,
            ICON = 26
        }
    }
    self.HP25_BUFF_BOX = {
        [1] = {
            ID = 5213133,
            BUFF_ID = 22, -- クリティカル
            VALUE = 50,
            DURATION = 999999,
            ICON = 11
        }
    }
    self.CHANGE_BUFF_BOX = {
        [1] = {
            ID = 5213134,
            BUFF_ID = 21, -- 被ダメ軽減
            VALUE = -95,
            DURATION = 5,
            ICON = 5
        }
    }
    self.FIRE_BUFF_BOX = {
        [1] = {
            ID = 5213135,
            BUFF_ID = 61, -- 炎無効
            VALUE = 1000,
            DURATION = 999999,
            ICON = 38
        },
        [2] = {
            ID = 5213136,
            BUFF_ID = 27, -- 炎無効
            VALUE = -1000,
            DURATION = 999999,
            ICON = 0,
            SCRIPT = 215,
            SCRIPTVALUE1 = kElementType_Fire
        }
    }
    self.DARK_BUFF_BOX = {
        [1] = {
            ID = 5213137,
            BUFF_ID = 65, -- 闇無効
            VALUE = 1000,
            DURATION = 999999,
            ICON = 42
        },
        [2] = {
            ID = 5213138,
            BUFF_ID = 27, -- 闇無効
            VALUE = -1000,
            DURATION = 999999,
            ICON = 0,
            SCRIPT = 215,
            SCRIPTVALUE1 = kElementType_Dark
        }
    }
    self.TIMEUP_BUFF_BOX_LIST = {
        [1] = {
            ID = 5000033,
            BUFF_ID = 17,      --ダメージ
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 5000036,
            BUFF_ID = 13,      --攻撃力
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 3
        }
    }
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
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);
    event.unit:setAttackDelay(2);

    self.gameUnit:setSkin("normal")
    self:setTriggerList()
    self:setMessageBoxList()
    self:setBuffBoxList()

    self:showMessage(self.START_MESSAGE_LIST)

    self.isAwaken = false
    self.isAwakened = false
    self.isFury = false
    self.negaTimer = 1.2
    self.LIMIT = 1.2
    self.hitStop = 1

    self:initAttackWeight({DARK_1 = 100})
    self:initSkillWeight({DARK_1 = 100})
    self.gameUnit:addSP(40)

    --テロップ用変数
    self.telopSpan = 60
    self.showMessageTimer = 0

    self.sickTimer = 30
    self.sickInterval = 30
    self.isSick = false
    self.isFreeze = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,self.hitStop)
    self:HPTriggersCheck(event.unit);
    self:negaChange(event.deltaTime)
    self:setTimeUp()
    self:checkSick(event.unit,event.deltaTime)
    self:checkFreeze(event.unit)
    return 1
end

function class:checkFreeze(unit)
    if unit:getBurstState() == kBurstState_active and not self.isFreeze and unit:getTeamUnitCondition():findConditionWithType(96) ~= nil then
        self.isFreeze = true
        self:showMessage(self.FREEZE_MESSAGE_LIST)
    end
end

function class:checkSick(unit,deltaTime)
    if self.sickTimer < self.sickInterval then
        if unit:getTeamUnitCondition():findConditionWithType(94) ~= nil then
            self.isSick = true
        else
            self.isSick = false
        end
        self.sickTimer = self.sickTimer + deltaTime
        return
    end

    if unit:getTeamUnitCondition():findConditionWithType(94) == nil then
        self.isSick = false
    end

    if unit:getTeamUnitCondition():findConditionWithType(94) ~= nil and not self.isSick then
        self.isSick = true
        self.sickTimer = 0
        self:showMessage(self.SICK_MESSAGE_LIST)
    end
end

function class:negaChange(deltaTime)
    if not self.isNega then return end

    if self.LIMIT >= self.negaTimer then
        self.negaTimer = self.negaTimer + deltaTime
    else
        self.isNega = false
        self.gameUnit:takeGrayScale(0.99)
        self:removeGrayScale(self.gameUnit)
    end
end

-- 一定時間ごとにテロップを流す
function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
        self.showMessageTimer = 0
        self:showMessages(self.START_MESSAGES)
    else
        self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

-- 180秒経ったらタイムアップ
function class:setTimeUp()
    if BattleControl:get():getTime() > 180 and not self.TRIGGERS[4].used then
        self:execTrigger(4)
    end
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    event.unit:setNextAnimationName("skill1")
    event.unit:setNextAnimationEffectName("1-skill1")
    if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "change" then
        self:change()
    end
    if event.spineEvent == "nega" then
        self:change()
    end
    --if event.spineEvent == "addSP" then
    --    self:addSP(event.unit);
    --end

    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    if not self.isAwakened then
        event.unit:setNextAnimationEffectName("out")
    else
        event.unit:setNextAnimationEffectName("out2")
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if not self.isAwakened then
        event.unit:setNextAnimationName("back")
    else
        event.unit:setNextAnimationName("back2")
    end
    return 1
end

function class:changeAwaken()
    self.isBreak = true
    if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
    -- self.isAwaken = not self.isAwaken
    self:removeConditionAll(self.gameUnit,93965200)
    self:removeConditionAll(self.gameUnit,93965300)
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if self.isSkilled then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
        if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
        self.isSkilled = false
        self:addBuff(self.gameUnit,self.CHANGE_BUFF_BOX)
        self.gameUnit:addSP(20)
        return 1
    end

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
    self:addSP(event.unit);
    return 1
end

function class:attackReroll(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self:weightController(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    if self.gameUnit.m_breaktime <= 0 then
        unit:addSP(self.spValue);
    end
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.isFreeze = false
    event.unit:setBurstState(kBurstState_active)
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
    self.isSkilled = true
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.isBreak then
        self.isBreak = false
        skillIndex = 1
    else
        self:weightController(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:removeGrayScale(unit)
    for i = 0,3 do
        local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
            u:takeGrayScale(0.99)
        end
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
    for i,messageBox in ipairs(messageBoxList) do
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
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
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
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
        unit:resumeUnit()
    end
end

function class:removeConditionAll(unit,buffId)
    while unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil do
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
        unit:resumeUnit()
    end
end

--===================================================================================================================
--その他
--===================================================================================================================
function class:weightController(SET_LIST,stateBox)
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

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
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





class:publish();

return class;