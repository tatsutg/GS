local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="37章_真EX極_十二代目ミズキ・七天装", version=2.6, id=3705029})
class:inheritFromUnit("unitBossBase")

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_C_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "哭霧自在",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_C_02",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "カイガン零式",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 6
}

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
        { SKILL3 = 100 }
    }
}

class.cutInSkill = {
    [5] = 4,
    [6] = 4
}

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 6,
        hitStop = 100,
        reflectDuration = 15,
        tgTimer = 15,
        tgLimit = 1,
        tgIconNum1 = 16,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        buffVal_31 = 5000,
        hpBuffValue_17 = 100
    })
    self:dump(self.GD)

    self.gameUnit = event.unit
    self.spValue = self.GD.addSP
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay)
    end

    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.cutInFLG = false
    event.unit:setSPGainValue(0)
    event.unit:setSkillInvocationWeight(0)

    self.hpMarkers = {}
    self.addSpSkipFLG = true
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.lastSkillFLG = false
    self.deadFlg = false
    self.fromHost = false
    self.reflectCount = 0
    self.lastAttacker = nil

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self:showMessage(self.START_MESSAGE_LIST)

    --ボスギミック
    self.reflectCount = 0;

    --エクストラタイマーギミック
    self.timeIndex = nil
    self.timeSpeed = nil

    ---カイガン関係
    self.isAura = false
    self.timer = 0
    self.gameUnit = event.unit
    self.AURA_INTERVAL = 999999
    self.SKILL5_REDUCE_TIMER = 30
    self.AURA_INTERVAL_WITH_TRUE_WEAPON = 30
    self.shinMode = false
    self:setSurfaceBoxList()
    return 1
end

function class:startWave(event)
    return 1
end

function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
        -- self:checkReflect(event.unit)
    end

    --カイガン関係
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)

    --状態異常反射
    self:reflectDeBuff(event.unit);

    ---エクストラタイマーギミック
    self:extraTimerOperation(event.unit);

    event.unit:setReduceHitStop(self.GD.hitStop, 1)
    return 1
end

function class:auraPosition(unit)
    if self.aura == nil then
        return
    end

    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
    if self.isAura then
    end
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            self.isAura = false
            self.timer = 0
            self:setBuffBoxList()
            -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
            --unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
            self.aura:takeAnimation(0,"empty",true);
            self.shinMode = false
            self.emptyFLG = false
        end
    end
end

function class:reflectDeBuff(unit)
    local badStatusList = {89, 91, 96};
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            local cond = unit:getTeamUnitCondition():findConditionWithType(v);
            if cond ~= nil then
                --付与したユニットを取得
                local targetUnit = self:getAncestorUnit(cond:getCaster())
                local buffValue = cond:getValue()
                local buffIcon = cond:getThumbnailID()
                local buffEffect = cond:getAnimationID()
                self.reflectCount = self.reflectCount + 1
                --状態異常を反射
                targetUnit:getTeamUnitCondition():addCondition(3705026, v, buffValue, self.GD.reflectDuration + self.reflectCount, buffIcon, buffEffect)
                self:showFormatMessage(self.DEBUFF_CANCEL_MESSAGE_LIST[v],targetUnit:getUnitName())
                --EXタイマーは削除する
                if self.timeIndex ~= nil then
                    self.timeSpeed = 1
                    megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed);
                    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
                    megast.Battle:getInstance():removeExtraTimer(self.timeIndex ,1 ,1 ,true);
                    self.timeIndex = nil;
                    self.timeSpeed = nil;
                end
                if megast.Battle:getInstance():isHost() then
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,7,v);
                end
            end
        end
    end
    self:refresh(unit)
end

function class:receive7(args)
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithType(args.arg);
    if cond ~= nil then
        --付与したユニットを取得
        local targetUnit = self:getAncestorUnit(cond:getCaster())
        local buffValue = cond:getValue()
        local buffIcon = cond:getThumbnailID()
        local buffEffect = cond:getAnimationID()
        -- self.reflectCount = self.reflectCount + 1
        --状態異常を反射
        targetUnit:getTeamUnitCondition():addCondition(3705026, args.arg, buffValue, self.GD.reflectDuration * self.reflectCount, buffIcon, buffEffect)
        -- self:showFormatMessage(self.DEBUFF_CANCEL_MESSAGE_LIST[args.arg],targetUnit:getUnitName())
    end
    -- self:refresh(self.gameUnit)
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndex then

    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local FLG = 0;
        -- 無敵中は停止
        if unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeed = 0;
        elseif FLG == 1 then
            self.timeSpeed = 1;
        else
            self.timeSpeed = 1;
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        end
    else
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.TG_BOX_LIST[1].ID);
        if cond ~= nil then
            unit:getTeamUnitCondition():removeCondition(cond);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "KaiganStart" then
        self:shinSetAura(event.unit)
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"Kaigan3_loop",true);
    end
    if event.spineEvent == "loopStart3" then
        self.aura:takeAnimation(0,"Kaigan3_loop",true);
    end
    if event.spineEvent == "auraReturn" then
        self.vanishFLG = false
    end
    if event.spineEvent == "auraVanish" then
        self.vanishFLG = true
    end
    return 1
end

function class:setAura(unit)
    --self:teamAddSP(unit,100)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:shinSetAura(unit)
    --self:teamAddSP(unit,100)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan3_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan3_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan3_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

---MD1オーラ
function class:loopStart1(unit)
    self.vanishFLG = false
    if self.loopStart1FLG then
        if self.shinMode then
            self:shinSetAura(unit)
        end
    end
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackReroll(event.unit)
    end
    self.attackCheckFlg = false
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1")
    end

    self.fromHost = false
    self:attackActiveSkillSetter(event.unit, event.index)

    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    else
        self:addSP(event.unit)
    end
    return 1
end

function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        return self:skillReroll(event.unit)
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    if self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index, 1)
        return 0
    end

    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    if event.index == 2 then
        self:execSkill2(event.unit)
    elseif event.index == 3 then
        self:execSkill3(event.unit)
    elseif event.index == 6 then
        self.shinMode = true
        event.unit:setNextAnimationName("S_Kaigan")
        event.unit:setNextAnimationEffectName("S_Kaigan")
    end

    self.skillCheckFlg = false
    self.cutInFLG = false
    self.addSpSkipFLG = true
    self.fromHost = false
    self:skillActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:execSkill2(unit)
end

function class:execSkill3(unit)
end

function class:execSkill5(unit)
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    end
    unit:takeAttack(tonumber(attackIndex))
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, tonumber(attackIndex))
    return 0
end

function class:takeAttackFromHost(unit, index)
    self.fromHost = true
    unit:takeAttack(index)
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL)
    end
    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex), self.cutInSkill[skillIndex])
    else
        unit:takeSkill(tonumber(skillIndex))
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, tonumber(skillIndex))
    return 0
end

function class:takeSkillFromHost(unit, index)
    self.fromHost = true
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index, self.cutInSkill[index])
    else
        unit:takeSkill(index)
    end
end

function class:takeDamageValue(event)
    if event.enemy ~= nil then
        local ancestor = self:getAncestorUnit(event.enemy)
        if ancestor ~= nil then
            self.lastAttacker = ancestor
        end
    end
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

function class:takeBreake(event)
    for i = 1, table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end
---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1
end

function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP], true)
    end
    return 1
end

function class:addSP(unit)
    unit:addSP(self.spValue)
    return 1
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "十二代目ミズキ、参る！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "水属性・人族ユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "反転術式：麻痺、氷結、気絶を反射", COLOR = Color.yellow})
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "クリティカルダメージアップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "開け、イマリの力！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "カイガン零式：与ダメージ・回避率アップ", COLOR = Color.yellow})
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "当代ミズキの名にかけて！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "一定時間回避率アップ：麻痺、氷結、気絶で解除", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ぐああああ！", COLOR = Color.cyan})
    }
    self.DEBUFF_CANCEL_MESSAGE_LIST = {
        [89] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CANCEL_MESSAGE1 or "%sに気絶を反射！", COLOR = Color.red, isPlayer = true}),
        [91] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CANCEL_MESSAGE2 or "%sに麻痺を反射！", COLOR = Color.red, isPlayer = true}),
        [96] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_CANCEL_MESSAGE3 or "%sに氷結を反射！", COLOR = Color.red, isPlayer = true})
    }
end

function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
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
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

function class:hp75(status)
    if status == "use3" then
        self:showMessage(self.HP75_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp25(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        -- self:refresh(self.gameUnit)
        self:showMessage(self.HP25_MESSAGE_LIST)
        --タイマー表示
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        self:execAddBuff(self.gameUnit, self.TG_BOX_LIST[1])
    end
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 37050291,
            BUFF_ID = 17,   --クリティカルダメージUP
            VALUE = self.GD.hpBuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        }
    }
    self.TG_BOX_LIST = {
        [1] = {
            ID = 37050292,
            BUFF_ID = 31,  --回避率アップ
            VALUE = self.GD.buffVal_31,
            DURATION = 16,
            ICON = 16
        }
    }
end

function class:showMessage(messageBoxList, index, targetUnit)
    if index == nil then
        self:showMessageAll(messageBoxList, targetUnit)
        return
    end
    self:execShowMessage(messageBoxList[index], targetUnit)
end

function class:showMessageAll(messageBoxList, targetUnit)
    for _, messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox, targetUnit)
    end
end

function class:execShowMessage(messageBox, targetUnit)
    local msg = messageBox.MESSAGE
    if targetUnit ~= nil then
        msg = string.format(msg, targetUnit:getUnitName())
    end
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(msg, messageBox.DURATION, messageBox.COLOR)
    else
        summoner.Utility.messageByEnemy(msg, messageBox.DURATION, messageBox.COLOR)
    end
end

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    end
end

function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

function class:execTrigger(index, receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost()
end

function class:adjustHpFlg(unit, value)
    local anotherHp = unit:getHP() - value
    for _, trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit, stopBorder, value)
        end
    end
    return value
end

function class:calcDamageValue(unit, border, value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

function class:execAddBuff(unit, buffBox)
    local buff = nil
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON, buffBox.EFFECT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON)
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
    end
end

function class:refresh(unit)
    local badStatusIDs = {89, 91, 96}
    for i = 1, table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i]
        local flag = true
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID)
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond)
            else
                flag = false
            end
            count = count + 1
            if count > 100 then break end
        end
    end
end

function class:checkReflect(unit)
    if not megast.Battle:getInstance():isHost() then return end
    local ailmentIDs = {89, 91, 96}
    for _, ailmentID in ipairs(ailmentIDs) do
        local cond = unit:getTeamUnitCondition():findConditionWithType(ailmentID)
        if cond ~= nil then
            if self.lastAttacker ~= nil and self.lastAttacker:getHP() > 0 then
                self:handleStatusAilmentReflect(self.lastAttacker, ailmentID)
            else
                self:refresh(unit)
            end
            return
        end
    end
end

function class:handleStatusAilmentReflect(sourceUnit, ailmentType)
    if megast.Battle:getInstance():isHost() then
        self:refresh(self.gameUnit)
        self.reflectCount = self.reflectCount + 1
        local reflectDuration = self.GD.reflectDuration + self.reflectCount
        local reflectBuff = {
            ID = 200069500 + ailmentType,
            BUFF_ID = ailmentType,
            VALUE = 100,
            DURATION = reflectDuration,
            ICON = 0
        }
        self:execAddBuff(sourceUnit, reflectBuff)
        local ailmentNames = {[91]="麻痺", [96]="凍結", [89]="気絶"}
        local msg = string.format("%sに%sを反射！", sourceUnit:getUnitName(), ailmentNames[ailmentType] or "状態異常")
        summoner.Utility.messageByPlayer(msg, 7, Color.red)
        megast.Battle:getInstance():sendEventToLua(self.scriptID, 7, ailmentType)
    end
end

function class:movePatternState(SET_LIST, stateBox)
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
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount])
    local attackIndex = string.gsub(attackStr, "ATTACK", "")
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr, "SKILL", "")
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




class:publish()
return class