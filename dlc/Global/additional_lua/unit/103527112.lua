local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒キリサメ", version=1.3, id=103527112});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_KAIGAN",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "我式・刀舞「焦熱地獄」",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_SINKAIGAN",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "シンカイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---タイマー用
        [1] = {
            ID = 1035271121,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0,
            LEVEL = 1
        },
        [2] = {
            ID = 1035271122,
            BUFF_ID = 21,---被ダメージ軽減
            VALUE = -30,
            DURATION = self.AURA_INTERVAL,
            ICON = 20,
            LEVEL = 1
        },
        [3] = {
            ID = 1035271123,
            BUFF_ID = 21, ---被ダメージ軽減(敵が燃焼状態)
            VALUE = -20,
            DURATION = self.AURA_INTERVAL,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 251,
                VALUE1 = 97
            },
            LEVEL = 1
        },
        [4] = {
            ID = 1035271124,
            BUFF_ID = 21, ---被ダメージ軽減(物理)
            VALUE = -20,
            DURATION = self.AURA_INTERVAL,
            ICON = 21,
            SCRIPT = {
                SCRIPT_ID = 4
            },
            LEVEL = 1
        },
        [5] = {
            ID = 1035271125,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0,
            LEVEL = 1
        },
        [6] = {
            ID = -103617312,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
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
    self.shinMode = false
    self:setSurfaceBoxList()

    self:setBuffBoxList()

    self.skill2FLG = false
    self.skill3FLG = false
    self.vanishFLG = false
    self.emptyFLG = false

    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.firstFLG == nil then
        self.firstFLG = false
        if self:findWeapon(event.unit,50278200) then
            self.AURA_INTERVAL = self.AURA_INTERVAL + 60
            self:setBuffBoxList()
        end
    end
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    if self.skill2FLG then
        self.skill2FLG = false
    end
    self:skill3Control(event.unit)
    return 1
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function class:skill3Control(unit)
    if self.skill3FLG then
        self.skill3FLG = false
        if not self.isAura then
            self.isAura = true
            self.timer = 0
            self.loopStart1FLG = true---オーラを出すためのフラグ
            if self:teamCheck(unit) then
                self.shinMode = true
                self:showShinTimer(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
            else
                self:showMDTimer(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
            end
        else
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
    elseif not self:teamCheck(unit) then
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
    if event.spineEvent == "vanish" then
        self.vanishFLG = true
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan1","Kaigan_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:shinSetAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan1","Kaigan2_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan2_in",true);
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

function class:teamCheck(unit)
    if unit:getLevel() < 1 then
        return false
    end
    local targetTeam = unit:getTeam()
    local FLG = false
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit ~= unit then
                if myTeamUnit:getRaceType() == 1 then
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
            self.skill2FLG = true
        end
    elseif event.index == 3 then
        self.skill2FLG = false
        self.skill3FLG = true
        if not self.isAura then
            if self:teamCheck(event.unit) then
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD2])
                event.unit:setNextAnimationName("shin_kaigan_begin")
                event.unit:setNextAnimationEffectName("empty")
            else
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
                event.unit:setNextAnimationName("kaigan_begin")
                event.unit:setNextAnimationEffectName("empty")
            end
        else
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[5])
            buff:setRemoveOnResetState(true);
        end
    elseif event.index == 5 then
        self.skill3FLG = false
        if self.isAura then
            self:removeIconCondition(event.unit,139)
            self:removeIconCondition(event.unit,139)
        end
        local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[6])
        buff:setRemoveOnResetState(true);
    end
    return 1
end

function class:removeIconCondition(unit,thumbnailId)
    local count = 0
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getThumbnailID() == thumbnailId and cond:getNumber() == -1 then
                cond:setThumbnailID(0)
                cond:setTime(0) --バフ除去
                break;
            end
        end
    end
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

function class:setSurface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    --unit:setCutinVoice2(surfaceBox.VOICE);
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
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
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

    return buff
end

class:publish();

return class;