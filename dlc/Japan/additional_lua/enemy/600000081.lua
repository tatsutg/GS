local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド炎怪鳥", version=1.3, id=600000081});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK3 = 50}
    },
    SKY = {
        { ATTACK4 = 50,ATTACK5 = 50 },
        { ATTACK5 = 50,ATTACK6 = 50 },
        { ATTACK6 = 50,ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50,SKILL2 = 50 },
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9,
    ATTACK7 = 1
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 600000080,
            BUFF_ID = 13,   ---攻撃力
            VALUE = 30,
            DURATION = 99999,
            ICON = 3,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        [2] = {
            ID = 600000080,
            BUFF_ID = 0,   ---消去用
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 600000080,
            BUFF_ID = 13,   ---攻撃力(オーラなし)
            VALUE = 30,
            DURATION = 99999,
            ICON = 3
        },
        [4] = {
            ID = 600000081,
            BUFF_ID = 97,   ---燃焼
            VALUE = 3000,
            DURATION = 600,
            ICON = 87
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "燃焼状態の敵からのダメージを軽減"})
    }
    self.TAKEOFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TAKEOFF_MESSAGE1 or "飛行状態：気絶・麻痺・氷結で解除",
                             COLOR = Color.red})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "灼熱の風が吹き荒れる！",
                             COLOR = Color.red})
    }
    self.LANDING_MESSAGE_LIST = {
        [89] = self:setMessageInfo({MESSAGE = self.TEXT.LANDING_MESSAGE1 or "気絶で 飛行状態 解除成功！",
                                   COLOR = Color.red}),
        [91] = self:setMessageInfo({MESSAGE = self.TEXT.LANDING_MESSAGE2 or "麻痺で 飛行状態 解除成功！",
                                   COLOR = Color.red}),
        [96] = self:setMessageInfo({MESSAGE = self.TEXT.LANDING_MESSAGE3 or "氷結で 飛行状態 解除成功！",
                                   COLOR = Color.red})
    }

    ---テロップ
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end
---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 0;---addSPの量
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
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true
    self.takeOffTable = {
        [1] = 20,
        [2] = 30,
        [3] = 90
    }
    self.isFlying = false
    self.SKILL3FLG = false
    self.InvincibleFLG = false
    self.timer = 0
    self.burnFLG = false
    event.unit:setSetupAnimationName("idle2");
    ---レイドターゲット設定初期
    self.TELOP_SPAN = 30;
    self.telopTimer = 0
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:skill3Aura(event.deltaTime)
    if self.isFlying then
        self:landing(event.unit)
    end
    ---レイド関係---
    if RaidControl:get() ~= nil then
        self:telop(event.deltaTime)
    end
    return 1
end

---skill3のオーラ表示を調節
function class:skill3Aura(deltaTime)
    if self.gameUnit:getInvincibleTime() > 0 and self.SKILL3FLG then
        self.SKILL3FLG = false
        self.InvincibleFLG = true
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[3])
    elseif self.InvincibleFLG then
        self.timer = self.timer + deltaTime
        if self.timer > 4.5 then
            self.timer = 0
            self.InvincibleFLG = false
            self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
        end
    end
    return 1;
end

---停止系状態異常を監視
function class:landing(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            self:antiBadCondition(targetID - 37)
            self.isFlying = false
            self.afterSkillFLG = true
            self:initAttackWeight({DEFAULT = 100})
            self.spValue = 0;---addSPの量
            self.gameUnit:setAttackDelay(10);---アタックディレイ
            self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])
            unit:setBurstPoint(0)
            self:execShowMessage(self.LANDING_MESSAGE_LIST[targetID])
            unit:setSetupAnimationName("idle2");
        end
    end
    return 1;
end

---状態異常耐性---
function class:antiBadCondition(buffID)
    local BUFF_LIST = {
        ID = 0,
        BUFF_ID = buffID,
        VALUE = 20,
        DURATION = 99999,
        ICON = buffID + 6
    }
    local BUFF_LIST2 = {
        ID = 0,
        BUFF_ID = buffID + 49,
        VALUE = 20,
        DURATION = 99999,
        ICON = 0
    }
    self:execAddBuff(self.gameUnit,BUFF_LIST)
    self:execAddBuff(self.gameUnit,BUFF_LIST2)
end

-- ---------------------------------------------------------------------------------
-- -- レイド関係メソッド
-- ---------------------------------------------------------------------------------
---画面上部テロップ関係---(update)
function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(2,3)
        if rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    --if event.spineEvent == "addSP" then return self:addSP(event.unit) end
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
        self.SKILL3FLG = false
        self.burnFLG = false
    else
        self:addSP(event.unit)
    end

    if event.index == 7 and self.isRage then
        self.isRage = false
        self.isFlying = true
        self.afterSkillFLG = true
        self:initAttackWeight({SKY = 100})
        self.spValue = 30;---addSPの量
        self.gameUnit:setAttackDelay(7);---アタックディレイ
        event.unit:setNextAnimationName("take_off")
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
        self:showMessage(self.TAKEOFF_MESSAGE_LIST)
        event.unit:setSetupAnimationName("idle");
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    self:takeOff(event.index)
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.isRage then
        attackIndex = 7
    else
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:takeOff(num)
    if num >= 4 then
        return
    end

    local result = math.random(1, 100)
    if result <= self.takeOffTable[num] then
        self.isRage = true
        self.gameUnit:setAttackDelay(1);---アタックディレイ
    end
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

    if event.index == 3 then
        self.SKILL3FLG = true
        self.burnFLG = true
        self:showMessage(self.SKILL3_MESSAGE_LIST)
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local cond = enemyUnit:getTeamUnitCondition():findConditionWithType(97);
    if cond ~= nil then
        event.value = event.value * 0.5
    end
    return event.value
end

---オービットが攻撃してるかもしれないのでご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local cond = enemyUnit:getTeamUnitCondition():findConditionWithType(97);
    if cond ~= nil then
        event.value = event.value * 0.3
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
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.burnFLG then
        self.burnFLG = false
        local myTeam = event.enemy:getTeam();
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.BUFF_LIST[4])
            end
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

function class:takeIdle(event)
    if not self.isFlying then
        event.unit:setNextAnimationName("idle2")
    end
    return 1;
end

function class:takeDamage(event)
    if not self.isFlying then
        event.unit:setNextAnimationName("damage2")
    end
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

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
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