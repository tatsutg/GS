local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超十二代目ミズキ", version=2.6, id=104267212});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_SP",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_C",
            SKILL_NAME = self.TEXT.AFTER_MD or "哭霧自在",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_SP",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "カイガン零式",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---カイガン状態 アビ クリティカル率100%UP
        [1] = {
            ID = 1111101,
            BUFF_ID = 22,
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 11,
        },
        ---カイガン状態 アビ スーパークリティカル率70%UP
        [2] = {
            ID = 1111102,
            BUFF_ID = 142,
            VALUE = 70,
            DURATION = self.AURA_INTERVAL,
            ICON = 229,
        },
        ---カイガン零式状態 アビ スーパークリティカル率30%UP
        [3] = {
            ID = 1111103,
            BUFF_ID = 142,
            VALUE = 30,
            DURATION = self.AURA_INTERVAL,
            ICON = 0,
        },
        ---カイガン零式状態 アビ 全ステータス30%UP
        [4] = {
            ID = 1111104,
            BUFF_ID = 2,
            VALUE = 30,
            DURATION = self.AURA_INTERVAL,
            ICON = 1,
        },
        [5] = {
            ID = 1111105,
            BUFF_ID = 13,
            VALUE = 30,
            DURATION = self.AURA_INTERVAL,
            ICON = 3,
        },
        [6] = {
            ID = 1111106,
            BUFF_ID = 15,
            VALUE = 30,
            DURATION = self.AURA_INTERVAL,
            ICON = 5,
        },
        ---カイガン状態 奥義 7秒間、味方全体の奥義ゲージ5自然上昇
        [8] = {
            ID = 1111108,
            BUFF_ID = 10,
            VALUE = 5,
            DURATION = 7,
            ICON = 36,
            GROUP_ID = 49851,
            PRIORITY = 35,
            SCRIPT = {
                SCRIPT_ID = 21,
                VALUE1 = 50,
                VALUE2 = 100
            },
        },
        ---カイガン状態 超奥義 20秒間、味方全体のクリティカルダメージ300%UP
        [9] = {
            ID = 1111109,
            BUFF_ID = 17,
            VALUE = 300,
            DURATION = 20,
            ICON = 26,
            GROUP_ID = 1068,
            PRIORITY = 300,
            SCRIPT = {
                SCRIPT_ID = 22,
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    ---カイガン関係
    self.isAura = false
    self.timer = 0
    self.gameUnit = event.unit
    self.AURA_INTERVAL = 180
    self.SKILL5_REDUCE_TIMER = 30
    self.AURA_INTERVAL_WITH_TRUE_WEAPON = 30
    ---カイガン状態 スキル 奥義ゲージ20UP
    self.SP_VALUE = 20
    self.shinMode = false
    self:setSurfaceBoxList()
    --event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

    self.skill2FLG = false
    self.skill5FLG = false

    if self:findWeapon(event.unit,50331800) then
        self.AURA_INTERVAL = self.AURA_INTERVAL + self.AURA_INTERVAL_WITH_TRUE_WEAPON
    end

    self:setBuffBoxList()
    self.vanishFLG = false
    self.emptyFLG = false
    -- event.unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    return 1;
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if self:findWeapon(event.unit,50331800) then
        self.AURA_INTERVAL = self.AURA_INTERVAL + self.AURA_INTERVAL_WITH_TRUE_WEAPON
        self:setBuffBoxList()
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    if self.skill2FLG then
        self.skill2FLG = false
        self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[8])
    end
    if self.skill5FLG then
        -- 超奥義発動後カイガンタイマー調整
        if event.unit:getUnitState() ~= kUnitState_skill then
            if self.isAura then
                self.timer = self.timer + self.SKILL5_REDUCE_TIMER
                self:abilityBuffTimerReduce(event.unit)
            end
            self.skill5FLG = false
        end
    end
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
        ---超奥義
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
    elseif not self:playerRaceCheck(unit) then
        ---カイガン
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    else
        ---カイガン零式
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD2].VOICE)
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
        else
            self.timer = self.timer + deltaTime
            if self.vanishFLG and not self.emptyFLG then
                self.aura:takeAnimation(0,"empty",true);
                self.emptyFLG = true
            elseif not self.vanishFLG and self.emptyFLG then
                self.emptyFLG = false
                if self.shinMode then
                    self.aura:takeAnimation(0,"Kaigan3_loop",true);
                else
                    self.aura:takeAnimation(0,"Kaigan_loop",true);
                end
            end
        end
    end
end

-- アビリティバフタイマー調整
function class:abilityBuffTimerReduce(unit)
    for i = 1,6 do
        local Buff = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[i].ID)
        if Buff ~= nil then
            Buff:setTime(Buff:getTime() - self.SKILL5_REDUCE_TIMER)
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "KaiganStart" then
        if self.shinMode then
            self:shinSetAura(event.unit)
        else
            self:setAura(event.unit)
        end
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"Kaigan_loop",true);
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

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
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

---MD1オーラ
function class:loopStart1(unit)
    self.vanishFLG = false
    if self.loopStart1FLG then
        if self.shinMode then
            self:shinSetAura(unit)
        else
            self:setAura(unit)
        end
    end
end

-- 味方に人族がいるかチェック、いない場合零式状態にする
function class:playerRaceCheck(unit)
    local FLG = true
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i, true)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() ~= unit:getIndex() then
                if myTeamUnit:getRaceType() == 1 then
                    FLG = false
                end
            end
        end
    end
    return FLG
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    if event.index == 1 then
        -- スキル
        if self.isAura then
            self.gameUnit:addSPWithPvpCorrection(self.SP_VALUE);
        end
    elseif event.index == 2 then
        -- 奥義
        if self.isAura then
            self.skill2FLG = true
        end
    elseif event.index == 3 then
        -- 真奥義
        self.skill2FLG = false
    elseif event.index == 5 then
        -- 超奥義
        self.skill2FLG = false
        if not self.isAura then
            self.isAura = true
            self.timer = 0
            self.isBeforeSkill = true
            --event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
            self.loopStart1FLG = true---オーラを出すためのフラグ
            if self:playerRaceCheck(event.unit) then
                -- カイガン零式
                self.shinMode = true
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD2])
                event.unit:setNextAnimationName("S_Kaigan")
                event.unit:setNextAnimationEffectName("S_Kaigan")
                self:showShinTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])
            else
                -- カイガン
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
                event.unit:setNextAnimationName("S_Kaigan")
                event.unit:setNextAnimationEffectName("S_Kaigan")
                self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
            end
        else
            -- カイガン後の通常超奥義
            if self.shinMode then
                event.unit:setNextAnimationName("skill5")
                event.unit:setNextAnimationEffectName("2-skill5")
            else
                event.unit:setNextAnimationName("skill5")
                event.unit:setNextAnimationEffectName("2-skill5")
            end
            --self.vanishFLG = true
            self.skill5FLG = true
            self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[9])
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
        end
    end
    return 1
end

function class:setSurface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    -- unit:setCutinVoice3(surfaceBox.VOICE);
    --unit:setCutinSE2(surfaceBox.SE);
end

-- カイガンタイマー表示
function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_kaigan_time_gray.png","battle_kaigan_time.png",0,"unit/battle_trans_skill/frame_kaigan.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

-- カイガン零式タイマー表示
function class:showShinTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_shinkaigan_time_gray.png","battle_shinkaigan_time.png",0,"unit/battle_trans_skill/frame_kaigan.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

---------------------------------------------------------------------------------
-- バフ処理実行
---------------------------------------------------------------------------------
function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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
    return buff
end

class:publish();

return class;