local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ中編_真EX極_衛宮士郎", version=2.3, id=2048680});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL6 = 100 },
        { SKILL2 = 100, SKILL3 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL4 = 5,
    SKILL5 = 6,
    SKILL6 = 7,
    SKILL7 = 8
}

class.cutInSkill = {
    --[3] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 204868001,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 204868002,---背景変更主フラグ
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 204868003,---BGM変更主フラグ
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [4] = {
            ID = 204868004,---最終奥義フラグ
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [5] = {
            ID = 204868005,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
    self.BUFF_BOX = {
        [1] = {
            ID = 204868001,
            BUFF_ID = 31, --回避率
            VALUE = 20,
            DURATION = 999999,
            ICON = 16
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射無効",
            COLOR = Color.yellow
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "人族からの被ダメージアップ",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "闇・水属性ユニットからの被ダメージアップ",
            COLOR = Color.yellow
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "――体は剣でできている",
            COLOR = Color.cyan
        })
    }
    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "付き合えよ…",
            COLOR = Color.cyan
        })
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "俺は…間違えたのか…？",
            COLOR = Color.cyan
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp80(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self.hpSkill = 4
    end
end

function class:hp20(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self.hpSkill = 7
        self:showMessage(self.HP20_MESSAGE_LIST)
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
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST,1)
    self:showMessage(self.START_MESSAGE_LIST,2)
    self:showMessage(self.START_MESSAGE_LIST,3)

    self.addSpSkipFLG = false ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0

    self.startFLG = true

    ---------------------------------------------
    self.skill5FLG = false
    self.finalSkillFLG = false
    self.finalSkill = false
    self.timer = 0
    self.attackTime = 3
    self.num = 0
    self.BG_FLG = false
    self.midWaveFLG = false

    ---オービット
    self.orbitTime = 8
    self.count = self.orbitTime
    self.orbitDamage = 100
    self.skill5Damage = 1600

    if event.unit:getBurstSkill2() ~= nil then
        self:setDefaultBurstSkillRate2(event.unit)
    end
    ---------------------------------------------
    return 1
end

function class:setDefaultBurstSkillRate2(unit)
    if unit:getParameter("defaultDamageRate2") ~= "" then
        self.defaultDamageRate2 = unit:getParameter("defaultDamageRate2")
    else
        self.defaultDamageRate2 = unit:getBurstSkill2():getDamageRate()
        unit:setParameter("defaultDamageRate2",self.defaultDamageRate2)
    end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---hp100ギミック
    self.gameUnit:addSP(100)
    self.hpSkill = 5
    self.gameUnit:setInvincibleTime(12)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    ---背景変更処理
    if self.skill5FLG then
        self.skill5 = event.unit:getActiveBattleSkill()
        self.skill5FLG = false
        ---BGM処理
        self:allRemoveBuff(event.unit,self.BUFF_BOX_LIST[3].ID)---BGM主FLGを全体から削除
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])---BGM主FLGバフ
        BattleControl:get():playBGMTemporary("GS602_EMIYA",0,0);
    end

    ---背景変更前に失敗した場合
    if event.unit:getUnitState() ~= kUnitState_skill and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:BGMDelete(event.unit)
    end

    if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
        if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID) == nil then
            ---タイマー切れの場合(かつ超奥義中でない場合)
            self:BGDelete(event.unit)
        end
    end
    return 1
end

function class:BGChange(unit)
    unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)---自身からBGMFLGを削除
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])---タイマー用バフ
    self:showTimer(unit,self.BUFF_BOX_LIST[1].ID)---タイマー表示
    ---背景処理
    self:allRemoveBuff(unit,self.BUFF_BOX_LIST[2].ID)---背景主FLGを全体から削除
    self:execAddBuff(unit,self.BUFF_BOX_LIST[2])---背景主FLGバフ
    megast.Battle:getInstance():whiteOut(0,0.5,0.5);---ここでもホワイトアウトしておく
    BattleControl:get():setCustomBackgroundLWF(2035000)
    ---効果関係処理
    --unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2 * 2)---真奥義ダメージ2倍
    
    self:showMessage(self.START_MESSAGE_LIST,4)
end

function class:BGDelete(unit)
    ---背景主かどうか調べる
    if unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID) ~= nil then
        ---背景処理
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)---自身からFLGを削除
        megast.Battle:getInstance():whiteOut(0,0.5,0.5);---ここでもホワイトアウトしておく
        BattleControl:get():setDefaultBackgroundLWF();
        ---BGM処理
        if not self:allFindBuff(unit,self.BUFF_BOX_LIST[3].ID) then
            BattleControl:get():playPrevBGM();
        end
        ---オービットFLG
        self.count = self.orbitTime
        ---効果関係処理
        --unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2)---真奥義ダメージ元に戻す
    end
end

function class:BGMDelete(unit)
    ---BGM主かどうか調べる
    if unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID) ~= nil then
        ---背景処理
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)---自身からFLGを削除
    ---BGM処理
    BattleControl:get():playPrevBGM();
    end
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_xp_trans_equipment_time_gray_107777212.png","battle_xp_trans_equipment_time_107777212.png",0,"unit/battle_trans_skill/frame_107777212.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:allRemoveBuff(unit,buffId)
    local targetTeam = nil
    for b = 0,1 do
        if b == 1 then
            targetTeam = megast.Battle:getInstance():getTeam(true)
        else
            targetTeam = megast.Battle:getInstance():getTeam(false)
        end
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(buffId)
                end
            end
        end
    end
end

function class:allFindBuff(unit,buffId)
    local FLG = false
    local targetTeam = nil
    for b = 0,1 do
        if b == 1 then
            targetTeam = megast.Battle:getInstance():getTeam(true)
        else
            targetTeam = megast.Battle:getInstance():getTeam(false)
        end
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
                    FLG = true
                end
            end
        end
    end
    return FLG
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "BGChange" then
        self:BGChange(event.unit)
    end

    if event.spineEvent == "SK5" then
        event.unit:addOrbitSystem("SK5");
    end

    if event.spineEvent == "swordDelete" then
        self.sword = nil
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(83);
    if cond == nil then
        self:BGDelete(event.unit)
        self:BGMDelete(event.unit)
    end

    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:BGDelete(self.gameUnit)
    self:BGMDelete(self.gameUnit)
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    --------------------------------------------------------------------------------------
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
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if self.startFLG then
        self.startFLG = false
        if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
            self.skill5FLG = true
        else
            event.unit:setNextAnimationName("skill5_2")
            event.unit:setNextAnimationEffectName("skill5_2")
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            self:showTimer(event.unit,self.BUFF_BOX_LIST[5].ID)---タイマー非表示
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
            buff:setRemoveOnResetState(true)
            ---ダメージ修正
            if self.skill5 ~= nil then
                --self.skill5:setDamageRate(self.skill5Damage)
            end
        end
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
    elseif event.index == 5 then
        event.unit:setNextAnimationName("skill5")
        event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
    elseif event.index == 6 then
        event.unit:setNextAnimationName("skill5_2")
        event.unit:setNextAnimationEffectName("2-skill5_2") ---EFのアニメーション名に気をつける end
        self:execAddBuff(event.unit,self.BUFF_BOX[1])
    elseif event.index == 7 then
        event.unit:setNextAnimationName("skill5_2")
        event.unit:setNextAnimationEffectName("2-skill5_2") ---EFのアニメーション名に気をつける end
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
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