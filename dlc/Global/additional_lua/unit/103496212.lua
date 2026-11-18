local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="十二代目ミヅキ", version=1.3, id=103496212});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "七天最終奥義「水天彷彿」",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B_02",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "シンカイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---スキルCT100
        [1] = {
            ID = 1034962121,
            BUFF_ID = 29,
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 34,
            LEVEL = 70
        },
        ---攻撃力100
        [2] = {
            ID = 1034962122,
            BUFF_ID = 13,
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 3,
            LEVEL = 70
        },
        ---魔族・竜族へのダメージアップ
        [3] = {
            ID = 1034962123,
            BUFF_ID = 17, ---与ダメージアップ
            VALUE = 200,
            DURATION = self.AURA_INTERVAL,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 273,
                VALUE1 = 6,
                VALUE2 = 8
            }
        },
        ---物理ダメージ増加
        [4] = {
            ID = 1034962124,
            BUFF_ID = 21,
            VALUE = 60,
            DURATION = 15,
            ICON = 185,
            SCRIPT = {
                SCRIPT_ID = 4
            },
            GROUP_ID = 2067,
            PRIORITY = 60
        },
        ---奥義ゲージ自然上昇
        [5] = {
            ID = 1034962125,
            BUFF_ID = 10,
            VALUE = 4,
            DURATION = 15,
            ICON = 36,
            SCRIPT = {
                SCRIPT_ID = 21,
                VALUE1 = 50,
                VALUE2 = 100
            },
            GROUP_ID = 49851,
            PRIORITY = 60
        },
        ---与ダメアップ
        [6] = {
            ID = 1034962126,
            BUFF_ID = 17,
            VALUE = 100,
            DURATION = 15,
            ICON = 26,
            GROUP_ID = 24,
            PRIORITY = 100
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
    self.AURA_INTERVAL = 120
    self.shinMode = false
    self:setSurfaceBoxList()
    --event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

    self:setBuffBoxList()
    self.vanishFLG = false
    self.emptyFLG = false
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
        self:teamAddBuffElement(self.gameUnit,self.BUFF_BOX_LIST[6],2)
    end
    return 1
end

function class:teamAddBuffElement(unit,buffBox,element)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == element then
                self:execAddBuff(myTeamUnit,buffBox)
            end
        end
    end
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
        ---真奥義
        unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
    elseif not self:enemyCheck(unit) then
        ---カイガン
        unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    else
        ---シンカイガン
        unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD2].VOICE)
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
                    self.aura:takeAnimation(0,"Kaigan2_loop",true);
                else
                    self.aura:takeAnimation(0,"Kaigan_loop",true);
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "md2Start" then
        self:setAura(event.unit)
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"Kaigan_loop",true);
    end
    if event.spineEvent == "shinStart" then
        self:shinSetAura(event.unit)
    end
    if event.spineEvent == "loopStart2" then
        self.aura:takeAnimation(0,"Kaigan2_loop",true);
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
    self:teamAddSP(unit,100)
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
    self:teamAddSP(unit,100)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan2_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:teamAddSP(unit,sp)
    if unit:getLevel() < 70 then
        return
    end
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:addSPWithPvpCorrection(sp);
        end
    end
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

function class:enemyCheck(unit)
    if unit:getLevel() < 70 then
        return false
    end
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    local FLG = false
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit == targetTeam:getBoss() then
                if myTeamUnit:getRaceType() == 6 then
                    FLG = true
                elseif myTeamUnit:getRaceType() == 8 then
                    FLG = true
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
    if event.index == 2 then
        if self.shinMode then
            event.unit:setNextAnimationEffectName("shin_skill2")
            self.skill2FLG = true
        end
    elseif event.index == 3 then
        self.skill2FLG = false
        if not self.isAura then
            self.isAura = true
            self.timer = 0
            self.isBeforeSkill = true
            --event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
            self.loopStart1FLG = true---オーラを出すためのフラグ
            if self:enemyCheck(event.unit) then
                self.shinMode = true
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD2])
                event.unit:setNextAnimationName("shin_skill3")
                event.unit:setNextAnimationEffectName("empty")
                self:showShinTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
            else
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
                event.unit:setNextAnimationName("skill3")
                event.unit:setNextAnimationEffectName("empty")
                self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
            end
        else
            if self.shinMode then
                event.unit:setNextAnimationName("skill3b")
                event.unit:setNextAnimationEffectName("shin_skill3b")
            else
                event.unit:setNextAnimationName("skill3b")
                event.unit:setNextAnimationEffectName("skill3b")
            end
            self.vanishFLG = true
            self:enemyAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
            self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
        end
    end
    return 1
end

function class:setSurface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    -- unit:setCutinVoice2(surfaceBox.VOICE);
    --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_kaigan_time_gray.png","battle_kaigan_time.png",0,"unit/battle_trans_skill/frame_kaigan.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:showShinTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_shinkaigan_time_gray.png","battle_shinkaigan_time.png",0,"unit/battle_trans_skill/frame_kaigan.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local buff  = nil;
    ---レベルによっては効果なし
    if buffBox.LEVEL ~= nil then
        if buffBox.LEVEL > self.gameUnit:getLevel() then
            buffBox.BUFF_ID = 0
            buffBox.VALUE = 0
            buffBox.ICON = 0
        end
    end

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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end


class:publish();

return class;