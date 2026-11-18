--@additionalEnemy,1038,1039
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山モルドーラ", version=1.3, id="mine_6010"});
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
        { SKILL1 = 100 },
        { SKILL2 = 100 }
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
    self.HP50_BUFF_LIST = {
        [1] = {
            ID = 20054351,
            BUFF_ID = 28,   -- 攻撃速度
            VALUE = 20,
            DURATION = 99999,
            ICON = 7
        },
        [2] = {
            ID = 20054352,
            BUFF_ID = 13, -- 攻撃力
            VALUE = 100,
            DURATION = 99999,
            ICON = 3
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "庇うキラー・反射耐性・奥義ゲージ低下耐性",COLOR = Color.green})
    }

    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "モルドーラの体数分ボスの与ダメージUP",COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "子分モルドーラは毒・燃焼ダメージ以外無効",COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "ラグべロスの体数分ボスの全属性耐性UP",COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE4 or "ラグべロスは防御力が高い！",COLOR = Color.green}),
    }

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "軽減不可の固定ダメージによる攻撃！",COLOR = Color.green})
    }

    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "窮地の親分は緊急招集をかけた！",COLOR = Color.green})
    }

    self.TIMEUP_BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TIME_UP_ID = 3
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
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

function class:hp50(status)
    if status == "use3" then
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.isRage = true
        self.gameUnit:addSP(100)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.summonCount = 2
        self:showMessage(self.HP30_MESSAGE_LIST)
    end
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.KOMORU_ID = 1038
class.RAG_ID = 1039
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

    event.unit:addSP(100)
    self.summonCount = 1

    --テロップ用変数
    self.telopSpan = 60
    self.showMessageTimer = 0


    self.randR = 0
    self.randL = 0
    self.RuTimer = 0
    self.isRuHolding = false
    self.seeds = {}
    self.consts = {
        attack1Rate = 30,
        attack2Rate = 30,
        attack3Rate = 40,
        seedRate = 30, --種を飛ばす確率の基礎％　ここに現在のHPの減少割合/2の値が足される
        seedHP = 4000
    }

    event.unit:takeAnimation(1,"bud",true);
    event.unit:setSetupAnimationName("setUpBud");

    --テロップ用変数
    self.telopSpan = 60
    self.showMessageTimer = 0

    self.isFirstSummon = false

    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if self.RuTimer > 0 then
        return 0;
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.RuTimer > 0 then
        return 0;
    end

    local hpparcent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
    if hpparcent < 60 then
        event.unit:setNextAnimationName("idle1");
    elseif hpparcent < 30 then
        event.unit:setNextAnimationName("idle2");
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,2)
    self:HPTriggersCheck(event.unit)
    self:setTimeUp()
    self:telopCheck(event.deltaTime)
    if self.RuTimer > 0 then
        self.RuTimer = self.RuTimer - event.deltaTime;
    end
    return 1
end

-- 180秒経ったらタイムアップ
function class:setTimeUp()
    if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TIME_UP_ID].used then
        self:execTrigger(self.TIME_UP_ID)
    end
end

-- 一定時間ごとにテロップを流す
function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
        self.showMessageTimer = 0
        self:showMessage(self.START_MESSAGE_LIST)
    else
        self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end


---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreakeU(event)
    if self.isRuHolding and event.unit == self.gameUnit then
        event.unit:takeAnimation(1,"holdEnd",false);
        event.unit:takeAnimation(0,"ru_falldown",false);
        event.unit:setSetupAnimationName("");
        self.isRuHolding = false;
        self.RuTimer = 3;
        event.unit:setAttackTimer(5);
        return 0;
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "seedR" then return self:seedR(event.unit) end
    if event.spineEvent == "seedL" then return self:seedL(event.unit) end
    if event.spineEvent == "skill3Start" then return self:skill3Start(event.unit) end
    if event.spineEvent == "skill3End" then return self:skill3End(event.unit) end
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "seedEnd" then return self:seedEnd(event.unit) end
    if event.spineEvent == "setSeedZOrder" then return self:setSeedZOrder(event.unit) end
    if event.spineEvent == "ruEnd" then return self:ruEnd(event.unit) end
    return 1;
end

function class:seedR(unit)
    local orbitsystemName = "seedRtype1";
    if self.randR <= 30 then
        orbitsystemName = "seedRtype1";
    elseif self.randR < 60 then
        orbitsystemName = "seedRtype2";
    else
        orbitsystemName = "seedRtype3";
    end
    local seed = unit:addOrbitSystem(orbitsystemName,2);
    seed:setHitCountMax(999);
    seed:setEndAnimationName("seedEnd");
    seed:setActiveSkill(4);
    seed:setBaseHP(self.consts.seedHP);
    seed:setHP(self.consts.seedHP);
    table.insert(self.seeds,seed);
    return 1;
end

function class:seedL(unit)
    local orbitsystemName = "seedLtype1";
    if self.randL <= 30 then
        orbitsystemName = "seedLtype1";
    elseif self.randL < 60 then
        orbitsystemName = "seedLtype2";
    else
        orbitsystemName = "seedLtype3";
    end
    local seed = unit:addOrbitSystem(orbitsystemName,2);
    seed:setHitCountMax(999);
    seed:setEndAnimationName("seedEnd");
    seed:setActiveSkill(4);
    seed:setBaseHP(self.consts.seedHP);
    seed:setHP(self.consts.seedHP);
    table.insert(self.seeds,seed);
    return 1;
end

function class:setSeedZOrder(unit)
    unit:setZOrder(-(unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN")) + 3000);
    unit:enableShadow(true);
    return 1
end
function class:skill3Start(unit)
    self.isSkill3 = true
    return 1
end

function class:skill3End(unit)
    self.isSkill3 = false
    return 1
end

function class:seedEnd(unit)
    local  atari = 0;
    for i = 1,table.maxn(self.seeds) do
        print("Destroy")
        if self.seeds[i] == unit then
            atari = i
        end

    end
    if atari ~= 0 then
        table.remove(self.seeds,atari);
    end
    return 1
end

function class:ruEnd(unit)
    self.RuTimer = 0
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.RuTimer > 0  and event.unit == self.gameUnit then
        return 0;
    end

    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:findUnit()
    return 1
end

function class:findUnit()
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
        if teamUnit ~= nil then
            teamUnit:setHP(0)
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and self.isSkill1 then
        event.value = 12000 / 5
        event.value = event.enemy:getHP() - event.value < 1 and event.enemy:getHP() - 1 or event.value
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.isSkill1 = false
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
        self:checkSeed(event.unit)
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

function class:checkSeed(unit)
    --種がない場合はまず先に種飛ばし判定
    if table.maxn(self.seeds) <= 0 then
        local rand2 = LuaUtilities.rand(0,100);
        local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

        --HPが少なければ少ないほど種を飛ばしやすくなる
        if rand2 <= self.consts.seedRate + (100 - hpparcent)/2 then
            self.randR = LuaUtilities.rand(0,100);
            self.randL = LuaUtilities.rand(0,100);
        end
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

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    if event.index ~= 3 then
        self.isSkill1 = false
        if not self.isFirstSummon then
            self.isFirstSummon = true
            self:showMessage(self.SUMMON_MESSAGE_LIST)
        end
        self:summon(event.unit,self.KOMORU_ID,self.summonCount)
        self:summon(event.unit,self.RAG_ID,self.summonCount)
    end
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)

    if self.isRage then
        self:summon(unit,self.KOMORU_ID,1)
        self.isSkill1 = true
        self.isRage = false
        skillIndex = 3
    end

    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

function class:summon(unit,unitID,count)
    local thisCount = 0
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                thisCount = thisCount + 1
                if thisCount == count then
                    break
                end
            end
        end
    end
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
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end



function class:addBuff(unit,buffBoxList)
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


class:publish();

return class;