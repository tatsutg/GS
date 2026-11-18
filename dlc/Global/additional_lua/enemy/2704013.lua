local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="27章hard聖騎士ロイ", version=1.3, id=2704013});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK3=50},
        {ATTACK1=50},
        {ATTACK1=50, ATTACK2=50},
        {ATTACK1=50, ATTACK2=50},
        {ATTACK1=50, ATTACK2=50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 }
    },
    HP0 = {
        { SKILL4 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL3 = 4,
    SKILL4 = 5,
    SKILL5 = 5,
    SKILL7 = 6
}

class.cutInSkill = {
    [5] = 1,
    [7] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 27040131,
            BUFF_ID = 59,
            VALUE = -30,
            DURATION = 99999,
            ICON = 75,
            MAX = 10
        },
        [2] = {
            ID = 27040132,
            BUFF_ID = 17,
            VALUE = 20,
            DURATION = 99999,
            ICON = 26
        },
        [3] = {
            ID = 27040133,
            BUFF_ID = 31,---物理回避率
            VALUE = 30,
            DURATION = 99999,
            ICON = 16,
            SCRIPT = {
                SCRIPT_ID = 4
            }
        },
        [4] = {
            ID = 27040134,
            BUFF_ID = 108,
            VALUE = -30,
            DURATION = 99999,
            ICON = 0,
            MAX = 10
        }
    }

    self.TARGET_BUFF_LIST1 = {
        ID = 27040135,
        BUFF_ID = 23, ---被クリティカル率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 27040135,
        BUFF_ID = 0,
        VALUE = 0,
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
    self.TRUE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_MESSAGE1 or "レイアス、お前が最後のピースだ", COLOR = Color.cyan})
    }
    self.FALSE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_MESSAGE1 or "ようやく始められる", COLOR = Color.cyan})
    }
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・クリティカル耐性", COLOR = Color.yellow})
    }
    self.TRUE2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE2_MESSAGE1 or "レイアスをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE2_MESSAGE2 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "氷結耐性低下", COLOR = Color.red})
    }
    self.TRUE_HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_HP80_MESSAGE1 or "レイアス、全力で来い……！", COLOR = Color.cyan})
    }
    self.FALSE_HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_HP80_MESSAGE1 or "聖剣グラディウスよ", COLOR = Color.cyan})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "与ダメージ・物理回避率アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "お前の動きは覚えた", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "鉄壁状態：ブレイクで解除", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "さあ、罪を暴き出せ", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.TRUE_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TRUE_DEAD_MESSAGE1 or "レイアス、真なる王に……さぁ……", COLOR = Color.cyan})
    }
    self.FALSE_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FALSE_DEAD_MESSAGE1 or "あと一手だと言うのに……", COLOR = Color.cyan})
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
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp80(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        if self.isProtagonist then
            self:showMessage(self.TRUE_HP80_MESSAGE_LIST)
        else
            self:showMessage(self.FALSE_HP80_MESSAGE_LIST)
        end
        self:showMessage(self.HP80_MESSAGE_LIST)
        self.hpSkill = 5
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self.gameUnit:setInvincibleTime(10);
    end
end

function class:hp50(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 5
        self.breakFLG = true
        self.gameUnit:setInvincibleTime(10);
    end
end

function class:hp0(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP0_MESSAGE_LIST)
        self.hpSkill = 7
        self.hp0FLG = true
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * 0.4)
        self.spValue = 20;---addSPの量
        self.gameUnit:setInvincibleTime(10);
        self:initSkillWeight({HP0 = 100})
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 5;---addSPの量
    event.unit:setAttackDelay(1);---アタックディレイ
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
    if self:findTheProtagonist(event.unit) then
        self:showMessage(self.TRUE_MESSAGE_LIST)
        self.isProtagonist = true
        event.unit:setBattleStartVoice("VOICE_BATTLESTART_B")
    else
        self:showMessage(self.FALSE_MESSAGE_LIST)
        self.isProtagonist = false
    end
    self:showMessage(self.START_MESSAGE_LIST)
    if self.isProtagonist then
        self:showMessage(self.TRUE2_MESSAGE_LIST)
    end
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.saveBP = 0

    self.hp0FLG = false

    self.breakFLG = false

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end

---レイアスサーチ
function class:findTheProtagonist(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getBaseID() == 10101 then
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.TARGET_BUFF_LIST1.ID);
                if cond == nil then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                    unit:setHateTarget(myTeamUnit)
                    unit:updateHateTarget();
                end
                return true
            end
        end
    end
    return false
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if event.spineEvent == "Library_PB_Hit" then
        local orbit = event.unit:addOrbitSystem("PB_Hit",0)
        orbit:setDamageRateOffset(1/2);
        orbit:setBreakRate(1/2);
        self.freezeFLG = true
    end
    if event.spineEvent == "Library_PB_back" then
        local orbit = event.unit:addOrbitSystem("PB_back",0)
    end
    if event.spineEvent == "freezeEnd" then
        self.freezeFLG = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    megast.Battle:getInstance():updateConditionView();
    event.unit:updateHateTarget();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    if not event.unit:isBreak() then
        self:HPTriggersCheck(event.unit)
    end
    self:findTheProtagonist(event.unit)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.hp0FLG then
        return 0
    end
    if self.isProtagonist then
        self:showMessage(self.TRUE_DEAD_MESSAGE_LIST)
    else
        self:showMessage(self.FALSE_DEAD_MESSAGE_LIST)
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    if self.isProtagonist then
        self:showMessage(self.TRUE_DEAD_MESSAGE_LIST)
    else
        self:showMessage(self.FALSE_DEAD_MESSAGE_LIST)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
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

    if event.index == 3 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
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
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 3 then
        self:enemyAddBuffProtect(event.unit,self.BUFF_BOX_LIST[1])
        self:enemyAddBuffProtect(event.unit,self.BUFF_BOX_LIST[4])
        self:showMessage(self.SKILL3_MESSAGE_LIST)
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill5")
        event.unit:setNextAnimationEffectName("2-skill5")
    end

    if event.index == 7 then
        event.unit:setNextAnimationName("skill5_PB")
        event.unit:setNextAnimationEffectName("2-skill5_PB")
        event.unit:setDamageRateOffset(1/2);
        event.unit:setBreakRate(1/2);
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

function class:enemyAddBuffProtect(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    local FLG = false
    local count = 1
    for i = 0,7 do
        local teamUnit = targetTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
                count = count + 1
            end
        end
    end
    ---庇うユニットがいる場合
    if FLG then
        for i = 0,7 do
            local teamUnit = targetTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for i = 1,count do
                        self:execAddBuff(teamUnit,buffBox)
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = targetTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,buffBox)
            end
        end
    end
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.breakFLG then
        event.value = 1
    end
    local enemyUnit = self:getAncestorUnit(event.enemy)
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

-- ご先祖ユニットまで遡る
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
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    local enemyUnit = self:getAncestorUnit(event.enemy)
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
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > 10 then
                count = 10
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