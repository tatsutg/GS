local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイドエミー", version=1.9, id=600000079});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK1 = 50,ATTACK3 = 50}
    },
    ADVANCED = {
        { ATTACK4 = 50,ATTACK5 = 50},
        { ATTACK5 = 50,ATTACK6 = 50},
        { ATTACK4 = 50,ATTACK6 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    },
    ADVANCED = {
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
    SKILL3 = 9
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 0,
        BUFF_ID = 23,
        VALUE = -80,
        DURATION = 99999,
        ICON = 188
    }
    self.TARGET_BUFF_BOX_LIST = {
        [1] = {
            ID = 501419,
            BUFF_ID = 17, -- ダメージ
            VALUE = 30,
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
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "闇属性耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒・病気・氷結状態のとき被ダメージアップ"})
    }
    self.ADVANCED_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ADVANCED_MESSAGE1 or "もういいや…全部、壊しちゃえ…",
                             COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.ADVANCED_MESSAGE2 or "クリティカル耐性アップ"}),
        self:setMessageInfo({MESSAGE = self.TEXT.ADVANCED_MESSAGE3 or "毒・病気・氷結耐性アップ"})
    }
    ---レイド関係---
    ---レイドメッセージ
    self.RAID_MESSAGES = {
        self:setMessageInfo({MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
                             COLOR = Color.red,
                             DURATION = 10})
    }
    ---テロップ
    self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
    self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
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
        self.isRage = true
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self.isChanged = false
    self.isSkill1 = false
    self.isAdvanced = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true
    ---ここまでいつもの

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * 0.06---サブバーのHP(最大体力の6%)
    self.damage = 0---サブバー表示時のダメージ

    ---レイドターゲット設定初期
    self.TELOP_SPAN = 30;
    self.telopTimer = 0
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    --self:HPTriggersCheck(event.unit)
    self:subBarControll(event.unit,self.damage);---サブバー表示
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    ---レイド関係---
    if RaidControl:get() ~= nil then
        self:telop(event.deltaTime)
    end
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        self.subBar:setVisible(false);
        ---サブHPが0になった場合の処理
        if not self.isChanged then
            self.isChanged = true---フラグを折る
            self.isRage = true---奥義7発動
            self.gameUnit:addSP(100)
        end
    end
end

---状態異常耐性---
function class:antiBadCondition(tbl)
    for key, value in pairs(tbl) do
        local BUFF_LIST = {
            ID = 0,
            BUFF_ID = value,
            VALUE = 20,
            DURATION = 99999,
            ICON = value + 6
        }
        local BUFF_LIST2 = {
            ID = 0,
            BUFF_ID = value + 49,
            VALUE = 20,
            DURATION = 99999,
            ICON = 0
        }
        self:execAddBuff(self.gameUnit,BUFF_LIST)
        self:execAddBuff(self.gameUnit,BUFF_LIST2)
    end
end

------------------------------------------------------------------------------------
-- executeAction
------------------------------------------------------------------------------------
function class:excuteAction(event)
    self.absorbFlg = false;
    ---レイド関係---
    if RaidControl:get() ~= nil then
        self:checkTarget()
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    --event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("change_in")
    return 1
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("idle_A");
    end
    ---奥義7後のパワーアップ処理
    if self.isSkill1 then
        self.isSkill1 = false
        self:showMessage(self.ADVANCED_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_LIST)---クリティカル耐性
        local badStatusIDs = {53,57,59};
        self:antiBadCondition(badStatusIDs)---毒、病気、氷結耐性
    end
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("back_A");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
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

    if event.index == 4 then
        event.unit:setNextAnimationName("attack1_A")
        event.unit:setNextAnimationEffectName("1-attack1")
    elseif event.index == 5 then
        event.unit:setNextAnimationName("attack2_A")
        event.unit:setNextAnimationEffectName("1-attack2")
    elseif event.index == 6 then
        event.unit:setNextAnimationName("attack3_A")
        event.unit:setNextAnimationEffectName("1-attack3")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        ---奥義7後のパワーアップ処理
        if self.isSkill1 then
            self.isSkill1 = false
            self:showMessage(self.ADVANCED_MESSAGE_LIST)
            self:execAddBuff(self.gameUnit,self.BUFF_LIST)---クリティカル耐性
            local badStatusIDs = {53,57,59};
            self:antiBadCondition(badStatusIDs)---毒、病気、氷結耐性
        end
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

    if self.isAdvanced then
        if event.index == 1 then
            event.unit:setNextAnimationName("skill1_A")
            event.unit:setNextAnimationEffectName("1-skill1")
        elseif event.index >= 2 then
            event.unit:setNextAnimationName("skill2_A")
            event.unit:setNextAnimationEffectName("1-skill2")
        end
    else
        if event.index >= 2 then
            event.unit:setNextAnimationName("skill2")
            event.unit:setNextAnimationEffectName("1-skill2")
        end
    end

    if event.index == 1 and self.isRage then
        self.isRage = false
        self.isSkill1 = true
        ---奥義7前のパワーアップ処理
        self.isAdvanced = true---パワーアップモード
        self:initAttackWeight({ADVANCED = 100})---行動パターン変化
        self:initSkillWeight({ADVANCED = 100})---行動パターン変化
        self.gameUnit:setAttackDelay(6);---アタックディレイ
    end
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 1
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    self.damage = self.damage + event.value
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

function class:addBuffAll(unit,buffBoxList)
    for _,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end
    unit:getTeamUnitCondition():removeCondition(buff);
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
-- ---------------------------------------------------------------------------------
-- -- レイド関係メソッド
-- ---------------------------------------------------------------------------------
---画面上部テロップ関係---(update)
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
---レイドターゲット判定---(executeAction)
function class:checkTarget()
    if not self.isTarget and self:getIsTarget() then
        self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
        self:showMessage(self.RAID_MESSAGES)
    end
    if self:getIsTarget() then
        BattleControl:get():showHateAll()
    else
        BattleControl:get():hideHateAll();
        self:removeBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)
    end
    self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
    return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

class:publish();

return class;