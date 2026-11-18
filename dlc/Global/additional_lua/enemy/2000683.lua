local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="マールゼクス", version=1.3, id=2000683});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 }
    },
    FIRE = {
        { ATTACK2 = 50 }
    },
    AQUA = {
        { ATTACK3 = 50 }
    },
    EARTH = {
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL4 = 100 },
        { SKILL1 = 100 },
        { SKILL5 = 100 },
        { SKILL2 = 100 },
        { SKILL4 = 100 },
        { SKILL2 = 100 },
        { SKILL5 = 100 },
        { SKILL3 = 100 },
        { SKILL4 = 100 },
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    },
    FIRE = {
        { SKILL2 = 100 },
        { SKILL4 = 100 },
        { SKILL2 = 100 },
        { SKILL5 = 100 },
    },
    AQUA = {
        { SKILL3 = 100 },
        { SKILL4 = 100 },
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    },
    EARTH = {
        { SKILL1 = 100 },
        { SKILL4 = 100 },
        { SKILL1 = 100 },
        { SKILL5 = 100 }
    },
    TIME_UP = { SKILL6 = 100 }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8,
    SKILL5 = 9,
    SKILL6 = 10
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20157501,
            BUFF_ID = 15, -- 防御力
            VALUE = 100,
            DURATION = 999999,
            ICON = 5
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "庇うキラー"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "防御無視攻撃時、奥義発動"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカル攻撃時、奥義発動"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "エンドレス発動毎にエンドレスの威力上昇"
        })
    }

    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE or "刹那の刻は真なる力を封殺する"
        })
    }

    self.HP15_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP15_MESSAGE or "世界は再び永劫の闇に染まる"
        })
    }

    self.OGI_HA_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.OGI_HA_MESSAGE1 or "永劫の闇は破盾の刃を封殺する"
        })
    }

    self.OGI_KYOKU_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.OGI_KYOKU_MESSAGE1 or "永劫の闇は致命の刃を封殺する"
        })
    }

end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TID_TIME_UP = 9
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp15(status) end,
            HP = 15,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [self.TID_TIME_UP] = {
            tag = "TIME",
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

function class:hp50(status)
    if status == "use3" then
        self.isHP50 = true
        self.gameUnit:addSP(100)
    end
end

function class:hp30(status)
    if status == "use3" then
        BattleControl:get():playBGM("GS502_THEMA");
        self.isRage = true
        self.gameUnit:addSP(100)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:initSkillWeight({CREATE_30 = 100})
    end
end

function class:hp15(status)
    if status == "use3" then
        self:showMessage(self.HP15_MESSAGE_LIST)
        self:initSkillWeight({CREATE = 100})
    end
end

function class:timeUp()
    if status == "use3" then

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
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    --self:showMessage(self.START_MESSAGE_LIST)

    self.ELEMENT_LIST = {
        [kElementType_Fire] = {count = 0,NAME = "FIRE"},
        [kElementType_Aqua] = {count = 0,NAME = "AQUA"},
        [kElementType_Earth] = {count = 0,NAME = "EARTH"},
        [kElementType_Light] = {count = 0,NAME = "DEFAULT"},
        [kElementType_Dark] = {count = 0,NAME = "DEFAULT"}
    }
    self:setElement()
    self.isChange = false
    self.mode = 0
    self.modeCache = 0
    self.current = ""
    self.nextActiveSkill = 0

    self.isMusi = false
    self.isCritical = false
    self.isOgi = false
    self.isSkill10 = false
    self.isFirst = false
    self.beforeSkill = 0
    self.isHP50 = false
    self.sliceValue = math.floor(8000 / 228)

    self:selectMode()
    self.timeLimit = 200
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    return 1
end

function class:setElement()
    for i = 0,3 do
        local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if unit ~= nil then
            local elementType = unit:getElementType()
            if elementType ~= kElementType_Light then
                self.ELEMENT_LIST[elementType].count = self.ELEMENT_LIST[elementType].count + 1
            end
        end
    end

    self:choiceElement(self.ELEMENT_LIST)
end

function class:choiceElement(list)
    self.SKILL_SET_LIST.CREATE = {}
    self.SKILL_SET_LIST.CREATE = self.SKILL_SET_LIST.DEFAULT
    local max = 0
    for _,element in pairs(list) do
        if max < element.count then
            max = element.count
            self.SKILL_SET_LIST.CREATE = self.SKILL_SET_LIST[element.NAME]
        elseif max == element.count and max >= 1 then
            for _,v in pairs(self.SKILL_SET_LIST[element.NAME]) do
                table.insert(self.SKILL_SET_LIST.CREATE,v)
            end
        end
    end
    self:initSkillWeight({CREATE = 100})
    self.SKILL_SET_LIST.CREATE_30 = {}
    for _,v in pairs(self.SKILL_SET_LIST.CREATE) do
        table.insert(self.SKILL_SET_LIST.CREATE_30,v)
    end
    --self.SKILL_SET_LIST.CREATE_30 = self.SKILL_SET_LIST.CREATE
    table.insert(self.SKILL_SET_LIST.CREATE_30,{SKILL6 = 100})

end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:HPTriggersCheck(event.unit)
    self:checkTimeUp()
    if self.TRIGGERS[1].used and not self.TRIGGERS[2].used then
        self:checkOgi()
    end

    return 1
end

function class:checkTimeUp()
    if BattleControl:get():getTime() > self.timeLimit and not self.TRIGGERS[self.TID_TIME_UP].used then
        self:execTrigger(self.TID_TIME_UP)
    end
    if self.TRIGGERS[self.TID_TIME_UP].used then
        self:addSP(self.gameUnit)
    end
end

function class:checkOgi()
    for i = 0,3 do
        local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if unit ~= nil then
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil and skill:isBurst2() then
                self.isOgi = true
                self.gameUnit:addSP(100)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)

    if event.unit:getBurstState() == kBurstState_active then
        return 1
    end

    if self:checkBuffList(event.enemy,{80,81}) and self.beforeSkill == 5 then
        self.isMusi = true
        self.gameUnit:addSP(100)
        return event.value
    end

    if self:checkCritical(event) and self.beforeSkill== 4 then
        self.isCritical = true
        self.gameUnit:addSP(100)
    end

    return event.value
end

function class:checkBuffList(unit,buffList)
    for _,id in ipairs(buffList) do
        local teamUnit = unit:getTeamUnitCondition():findConditionWithType(id)
        if teamUnit ~= nil then
            return true
        end
    end
    return false
end


function class:checkCritical(event)
    if event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
        return true
    end
    return false
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.TRIGGERS[self.TID_TIME_UP].used then
        return 99999
    end

    if self.isSkill10 then
        return self.sliceValue
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
    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
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
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if self.isChange then
        self:teleport(event.unit);
        return 0;
    end
    return 1;
end

function class:teleport(unit)
    self.isChange = false;
    self.isNormal = false
    local oldCache = self.modeCache
    self.mode = self:selectMode()
    local animName = "teleport"..self.mode;
    self:checkChangeTable()
    if self.mode == 1 or not self.isFirst then
        self.isFirst = true
        self:changeTable(unit);
        self.isNormal = true
    end
    if oldCache ~= self.modeCache and oldCache ~= 0 then
        animName = "teleport"..oldCache
    end
    unit:takeAnimation(0,animName,false);
    unit:takeAnimationEffect(0,"back",false);
    if not self.isNormal and self.STATE_SKILL.actCount ~= self.mode then
        self:changeTable(unit);
    end
    if (self.mode == 1 and self.isHand) or (self.mode ~= 1 and not self.isHand) then
        self:changeTable(unit);
        --summoner.Utility.messageByPlayer("change");
    end
end

function class:selectMode(check)
    local index = check
    if check == nil then
        index = #self.SKILL_SET_LIST[self.STATE_SKILL.setChar] < self.STATE_SKILL.actCount + 1 and 1 or self.STATE_SKILL.actCount + 1
    end
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][index]);
    local i = 0
    if skillStr == "SKILL1" then i = 2
    elseif skillStr == "SKILL2" then i = 3
    elseif skillStr == "SKILL3" then i = 4
    else i = 1 end
    return i
end

function class:checkChangeTable()
    if self.mode == 2 then
        if self.current ~= "setUpSword" then
            self.current = "setUpSword"
            self.modeCache = 2
        end
    end

    if self.mode == 3 then
        if self.current ~= "setUpSpear" then
            self.current = "setUpSpear"
            self.modeCache = 3
        end
    end

    if self.mode == 4 then
        if self.current ~= "setUpBow" then
            self.current = "setUpBow"
            self.modeCache = 4
        end
    end
end

function class:changeTable(unit)
    if self.mode == 2 then
        self:initAttackWeight({FIRE = 100})
        unit:setSetupAnimationName("setUpSword");
        if self.current ~= "setUpSword" then
            self.current = "setUpSword"
            self.modeCache = 2
        end
        self.isHand = true
        --self:showMessage(self.SWORD_MESSAGES);
    end

    if self.mode == 3 then
        self:initAttackWeight({AQUA = 100})
        unit:setSetupAnimationName("setUpSpear");
        --self:showMessage(self.LANCE_MESSAGES);
        if self.current ~= "setUpSpear" then
            self.current = "setUpSpear"
            self.modeCache = 3
        end
        self.isHand = true
    end

    if self.mode == 4 then
        self:initAttackWeight({EARTH = 100})
        unit:setSetupAnimationName("setUpBow");
        --self:showMessage(self.ARC_MESSAGES);
        if self.current ~= "setUpBow" then
            self.current = "setUpBow"
            self.modeCache = 4
        end
        self.isHand = true
    end

    if self.mode == 1 then
        self:initAttackWeight({DEFAULT = 100})
        unit:setSetupAnimationName("setUpNormal");
        self.isHand = false
    end
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.mode ~= 0 and self.mode ~= 1 then
        event.unit:setNextAnimationName("idle"..(self.mode));
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.mode ~= 0 and self.mode ~= 1 then
        event.unit:setNextAnimationName("back"..(self.mode));
    end
    return 1;
end
---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.isSkill10 = false
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
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self:weightController(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(tonumber(attackIndex));
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
    self.isChange = true
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        self.isSkill10 = false
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    --if event.index == 3 and not self.skillCheckFlg2 then
    --    self.skillCheckFlg2 = true;
    --    event.unit:takeSkillWithCutin(3,1);
    --    return 0;
    --end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if self.isChangeActiveSkill then
        self.isChangeActiveSkill = false
        event.unit:setActiveSkill(self.nextActiveSkill)
    end
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.isRage then
        self.isRage = false
        skillIndex = "6"
    elseif self.isHP50 then
        self.isHP50 = false
        skillStr = summoner.Random.sampleWeighted({SKILL4 = 50,SKILL5 = 50})
        skillIndex = string.gsub(skillStr,"SKILL","")
    elseif self.isOgi then
        self.isOgi = false
        skillIndex = "6"
    elseif self.isMusi then
        self.isMusi = false
        skillIndex = "4"
    elseif self.isCritical then
        self.isCritical = false
        skillIndex = "5"
    else
        self:weightController(self.SKILL_SET_LIST,self.STATE_SKILL)
    end


    if skillIndex == "4" then
        self.beforeSkill = 4
        self:showMessage(self.OGI_HA_MESSAGE_LIST)
    end
    if skillIndex == "5" then
        skillIndex = 4
        self.beforeSkill = 5
        self.isChangeActiveSkill = true
        self.nextActiveSkill = 9
        self:showMessage(self.OGI_KYOKU_MESSAGE_LIST)
    end

    if skillIndex == "6" then
        self.isSkill10 = true
        skillIndex = 4
        self.isChangeActiveSkill = true
        self.nextActiveSkill = 10
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

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


class:publish();

return class;