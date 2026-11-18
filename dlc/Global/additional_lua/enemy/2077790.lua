--@additionalEnemy,2077793
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="MSH6_モルク(真EX・極)", version=2.7, id=2077790});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50},
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 4,
    SKILL7 = 3,
    SKILL8 = 6,
}

class.cutInSkill = {
    [5] = 4,
    [6] = 1,
    [7] = 0,
    [8] = 4,
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 207779001,
            BUFF_ID = 21, --被ダメージアップ
            VALUE = self.GD.skill3BuffValue_21,
            DURATION = 999999,
            ICON = 139,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 207779002,
            BUFF_ID = 17, --クリティカルダメージアップ
            VALUE = self.GD.hp70BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        },
        [3] = {
            ID = 207779003,
            BUFF_ID = 0, --オーラ用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 05,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.GD.targetBuff_23,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 05,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 999999,
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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・被クリティカル攻撃耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "MSHユニットからの被ダメージアップ・ミーナスからは更にアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "累計ダメージの大きいユニットをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのクリティカル率アップ：ブレイクで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "クリティカル攻撃からの被ブレイクダメージアップ", COLOR = Color.yellow}),
    }
    self.WAVESTART_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.WAVESTART_MESSAGE1 or "喧嘩の時間だよ。夜露死苦ゥ！", COLOR = Color.cyan, DURATION = 4}),
        self:setMessageInfo({MESSAGE = self.TEXT.WAVESTART_MESSAGE2 or "ミーナス、おやすみの時間だよ", COLOR = Color.cyan, DURATION = 4}),
        self:setMessageInfo({MESSAGE = self.TEXT.WAVESTART_MESSAGE3 or "眠るのはオメーだぁああ！！", COLOR = Color.red, DURATION = 4, isPlayer = true}),
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "被ダメージアップ・奥義ゲージ減少", COLOR = Color.red, isPlayer = true}),
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ひどいよ…ハートブレイクだ…", COLOR = Color.cyan}),
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "逃がさない！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE2 or "クリティカルダメージアップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "思ってること、わかるよ", COLOR = Color.cyan}),
    }
    self.HP10_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE1 or "これが運命の赤い糸さ！！", COLOR = Color.cyan}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "負けた……ウソだろ、そんなはず……", COLOR = Color.cyan})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            isEnableSkip = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = true
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
            used = false,
            isEnableSkip = false
        },
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp70(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)

        -- 3体召喚
        if megast.Battle:getInstance():isHost() then
            self:findFriendAndSummon();
        end

        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp10(status)
    if status == "use3" then
        self.hp10state = 1
        --self.saveBP = self.gameUnit:getBurstPoint()
        --self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:showMessage(self.HP10_MESSAGE_LIST)
    end
end

function class:findFriendAndSummon()   --雑魚の監視
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID then
                self.friendCount = self.friendCount + 1;
            end
        end
    end

    if self.friendCount == 6 then  --何もしない
    elseif self.friendCount == 5 then
        self:MultipleSummon(self.summonEnemyID, 1);
    elseif self.friendCount == 4 then
        self:MultipleSummon(self.summonEnemyID, 2);
    else
        self:MultipleSummon(self.summonEnemyID, 3);
    end
end

--召喚するエネミーID、召喚回数
function class:MultipleSummon(eID, Num)
    local rtn = false
    for i = 1,Num do
        local summonEnemyUnit = self:Summon(self.gameUnit,eID)
        if summonEnemyUnit ~= nil then
            summonEnemyUnit:addSP(100)
        end
    end
    return rtn
end

---召喚系
---------------------------
function class:Summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                local addUnit = unit:getTeam():addUnit(i,unitID)
                return addUnit
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 6,
        hitStop = 100,
        startAddSP = 80,
        skill3BuffValue_21 = 10,
        hp70BuffValue_17 = 30,
        criticalTakeBreakDamageValue = 2.0,
        notCriticalTakeDamageValue = 0.5,
        targetBuff_23 = 120
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    -- ミーナスがいるかどうかでセリフ内容を変える
    self.startInfoState = 0
    self.infoCount = 0

    -- 召喚関連
    self.friendCount = 0
    self.summonEnemyID = 2077793

    -- ブレイクバッジ
    self.isBreak = false
    self.gameUnit:addNumBreakBadge(1)

    -- HP10トリガー関連
    self.hp10state = 0

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnit = nil
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.hateResetFlg = false

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.startInfoState = 1
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            -- ミーナスのBaseID
            if teamUnit:getBaseID3() == 407 then
                self.startInfoState = 2
            end
        end
    end
    if self.startInfoState == 1 then
        self:showMessage(self.WAVESTART_MESSAGE_LIST, self.startInfoState)
        self.startInfoState = 0
    elseif self.startInfoState == 2 then
        self:showMessage(self.WAVESTART_MESSAGE_LIST, self.startInfoState)
        self.startInfoState = self.startInfoState + 1
    end

    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:HPTriggersCheck(event.unit)
    end

    -- 戦闘開始時セリフInfo表示
    if self.startInfoState >= 2 then
        self.infoCount = self.infoCount + event.deltaTime
        if self.infoCount >= 4 then
            self:showMessage(self.WAVESTART_MESSAGE_LIST, self.startInfoState)
            self.startInfoState = self.startInfoState + 1
            self.infoCount = 0
            -- セリフが上限に達したら以降はやらない
            if self.startInfoState >= 4 then
                self.startInfoState = 0
            end
        end
    end

    if self.hp10state == 1 then
        self.hpSkill = 7
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.gameUnit:setAttackDelay(1);---アタックディレイ
        self.hp10state = 2
    end

    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill3_orbit" then
        local orbit = event.unit:addOrbitSystem("skill3_orbit",0)
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    if event.spineEvent == "Library_skill5_orbit" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit",0)
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    --if event.unit:getUnitState() ~= kUnitState_skill then
    --    if self.addSpSkipFLG then
    --        self.gameUnit:setInvincibleTime(0)
    --    end
    --end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    BattleControl:get():visibleHateTarget(false);
    self.gameUnit:setEnableHate(false);
    self.gameUnit:updateHateTarget();
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    BattleControl:get():visibleHateTarget(false);
    self.gameUnit:setEnableHate(false);
    self.gameUnit:updateHateTarget();
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

    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    -- 奥義３を３連続で発動し奥義６を発動
    if self.hp10state == 2 or self.hp10state == 3 then
        self.hpSkill = 2
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.hp10state = self.hp10state + 1
    elseif self.hp10state == 4 then
        self.hpSkill = 8
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
        self.hp10state = 5
    elseif self.hp10state == 5 then
        self.hp10state = 0
        self.gameUnit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
        self.gameUnit:setInvincibleTime(0)
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
        if self.hp10state == 0 then
            self.gameUnit:setInvincibleTime(0)
            event.unit:addSP(self.saveBP)
            self.saveBP = 0
        end
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

    --if self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if event.index == 2 then
        self:showMessage(self.SKILL3_MESSAGE_LIST)
        self:addSkillBuff()
    end

    if event.index == 3 or event.index == 6 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
    elseif event.index == 7 then
        self:showMessage(self.SKILL3_MESSAGE_LIST)
        self:addSkillBuff()
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
    elseif event.index == 5 or event.index == 8 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
        event.unit:setNextAnimationName("skill5")
        event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
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

function class:addSkillBuff()
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[1])
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    -- クリティカル以外の場合
    if not enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical then
        event.value = event.value * self.GD.notCriticalTakeDamageValue
    end

    event.value = self:adjustHpFlg(event.unit,event.value)

    -- オーラエフェクトが出ている時のみ適用
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID)
    if cond ~= nil then
        local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
        if self.targetUnitList[index] == nil then
            table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
        else
            self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
        end
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit()
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
            event.unit:setHateTarget(target)
            event.unit:updateHateTarget();
            ---ターゲットにバフ
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if i == target:getIndex() then
                        self.targetUnit = target
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                    else
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                    end
                end
            end
        end
    end

    return event.value
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0
        end
        if v.dps > val then
            val = v.dps
            target = v.unit
        end
    end

    --ターゲットを取得できなかった場合
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                target = myTeamUnit
                break;
            end
        end
    end

    return target
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self.targetUnit = target
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
            end
        end
    end
    return 1
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
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
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    -- クリティカルの場合
    if enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical then
        event.value = event.value * self.GD.criticalTakeBreakDamageValue
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

    self:showMessage(self.BREAK_MESSAGE_LIST)
    if not self.isBreak then
        self.isBreak = true
        self.gameUnit:removeNumBreakBadge()

        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID)
        if cond ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
        end

        ---ターゲットギミックを初期化
        BattleControl:get():visibleHateTarget(false);
        event.unit:setEnableHate(false);
        event.unit:updateHateTarget();
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
            end
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
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                ---ブレイクスルー
                self:execTrigger(index)
            end
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

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end


    self.TRIGGERS[index].action(action)
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

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
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

function class:checkDbuff(unit)
    local badStatusIDs = {89,91,96};
    local rtn = false
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            rtn = true;
        end
    end
    return rtn
end

class:publish();

return class;