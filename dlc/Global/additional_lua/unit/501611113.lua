local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="イフリート", version=1.3, id=501611113});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    --攻撃ルーチンの素リスト。setCharの選択対象。とりあえずAから名前を付けてるけれど、キー名は被らなければ別に何でもいい。
    A={
        --actCountの選択対象。重さは与えられず、上から順番に実行される。
        {
            --重さを与えてランダムに実行される。ATTACK_WEIGHTSと役割は同じ。
            ATTACK3 = 100
        },
        {
            ATTACK1 = 50,
            ATTACK2 = 50
        },
        {
            ATTACK1 = 50,
            ATTACK2 = 50,
            ATTACK3 = 50
        },
        {
            ATTACK1 = 50,
            ATTACK2 = 50
        },
        {
            ATTACK4 = 100
        }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    A={
        {
            SKILL3 = 100
        }
    },
    B={
        {
            SKILL1 = 100
        }
    },
    C={
        {
            SKILL2 = 100
        }
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
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 5016111131,
            BUFF_ID = 60, -- 燃焼耐性
            VALUE = -50,
            DURATION = 600,
            ICON = 76
        }
    }

    self.TARGET_BUFF_BOX_LIST = {
        [1] = {
            ID = 501299,
            BUFF_ID = 17, -- ダメージ
            VALUE = 100,
            DURATION = 999999,
            ICON = 26
        }
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 6,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "燃焼状態の敵に対してクリティカル率アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "炎属性攻撃無効"
        })
    }
    self.SKILL_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_MESSAGE1 or "星の怒りが聞こえるか…",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_MESSAGE2 or "我が炎が猛り狂う…",
            COLOR = Color.red
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_MESSAGE3 or "我に近づくこと叶わず…",
            COLOR = Color.red
        })
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "実に…楽しい闘いだった…",
            COLOR = Color.red
        })
    }

    -- レイドメッセージ
    self.RAID_MESSAGES = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red
        })
    }

    -- テロップ
    self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"

end

-- HP減少量（割合）
class.SLICE_RATIO = 0.7
class.TELOP_SPAN = 30;
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
    self.isFirst = true
    self:setMessageBoxList()
    self:setBuffBoxList()
    self:showMessage(self.START_MESSAGE_LIST)
    self.telopTimer = 0

    event.unit:setAttackDelay(0)
    event.unit:addSP(20)

    self:initAttackWeight({A = 100})
    self:initSkillWeight({A = 100}, {B = 100}, {C = 100})
    return 1
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
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)
    self:telop(event.deltaTime)
    return 1
end

function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

function class:excuteAction(event)
    self:checkTarget()
    return 1
end

-- 被ターゲット判定
function class:checkTarget()
    if not self.isTarget and self:getIsTarget() then
        self:execAddBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1])
        self:showMessage(self.RAID_MESSAGES)
    end
    if self:getIsTarget() then
         BattleControl:get():showHateAll()
    else
         BattleControl:get():hideHateAll();
        self:removeCondition(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)
    end
    self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
    return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "InTheBurst" then
        self:sliceHP()
    end
    if event.spineEvent == "addSP" then
        self:addSP(event.unit)
    end
    if event.spineEvent == "boostSP20" then
        event.unit:addSP(20)
    end
    if event.spineEvent == "boostSP40" then
        event.unit:addSP(40)
    end
    return 1
end

function class:sliceHP()
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            local shavedHPValue = localUnit:getHP() - (localUnit:getHP() * self.SLICE_RATIO)
            localUnit:setHP(shavedHPValue)
            self:execAddBuff(localUnit,self.BUFF_BOX_LIST[1])
        end
    end

end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
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

    -- if event.index == 3 and not self.skillCheckFlg2 then
    --     self.skillCheckFlg2 = true;
    --     event.unit:takeSkillWithCutin(3,1);
    --     return 0;
    -- end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self:execShowMessage(self.SKILL_MESSAGE_LIST[event.index])
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    self:weightController(self.SKILL_SET_LIST,self.STATE_SKILL)

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
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
    for _,messageBox in pairs(messageBoxList) do
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
function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

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

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
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

class:publish();

return class;