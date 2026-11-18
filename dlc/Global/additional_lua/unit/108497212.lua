local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="魔血クロエ(超覚醒)", version=1.3, id=108497212});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,                                   -- 【仮】
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",                -- 【仮】
            SKILL_NAME = self.TEXT.BEFORE_MD or "マギアドライブ", -- 【仮】
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"                -- 【仮】
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 5,                                   -- 【仮】
            VOICE = "VOICE_FULLARTS_CUTIN_B",                   -- 【仮】
            SKILL_NAME = self.TEXT.AFTER_MD or "超奥義（クロエ）", -- 【仮】
            SE = "SE_BATTLE_040_UNIT_CALL"                      -- 【仮】
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 108497212,
            BUFF_ID = 0, ---MDアイコンのみ
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        }
    }
    self.SKILL_BUFF_BOX_LIST = {
        [1] = {
            ID = 1084972000,
            BUFF_ID = 17, --- 【仮】
            VALUE = 200, -- 【仮】
            DURATION = 30, -- 【仮】
            ICON = 28, -- 【仮】
            SCRIPT = {
                SCRIPT_ID = 4, -- 【仮】
            },
            GROUP_ID = 1066, -- 【仮】
            PRIORITY = 200 -- 【仮】
        }
    }
    self.ABILITY_BOX_LIST = {
        [1] = {
            ID = 1084972001,
            BUFF_ID = 13, --- 【仮】
            VALUE = 100, -- 【仮】
            DURATION = self.AURA_INTERVAL,
            ICON = 3 -- 【仮】
        },
        [2] = {
            ID = 1084972002,
            BUFF_ID = 17, --- 【仮】
            VALUE = 200, -- 【仮】
            DURATION = self.AURA_INTERVAL,
            ICON = 31, -- 【仮】
            SCRIPT = {
                SCRIPT_ID = 58 -- 【仮】
            }
        },
        --追加効果
        [3] = {
            ID = 1084972003,
            BUFF_ID = 10, --- 【仮】
            VALUE = 2, -- 【仮】
            DURATION = self.AURA_INTERVAL,
            ICON = 36 -- 【仮】
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.isAura = false
    self.timer = 0
    self.gameUnit = event.unit
    self.AURA_INTERVAL = 180   --- 【仮】MD持続時間
    self:setSurfaceBoxList()

    self.skill5FLG = false     --- 超奥義(MD移行)フラグ
    self.loopStart1FLG = false --- MDオーラが出なかった場合のフラグ
    event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()

    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(), event.unit:getElementType());

    --超レオーネアビリティ対応（MD延長系）
    self.mdTime = self.AURA_INTERVAL;
    return 1
end

function class:findWeapon(unit, weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime, event.unit)

    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
    end
    self:skill5Control(event.unit)
    return 1
end

function class:skill5Control(unit)
    if self.skill5FLG then
        self.skill5FLG = false
        if not self.isAura then
            ---MD移行（1段階：移行時にMDバフを一括付与）
            self.isAura = true
            self.loopStart1FLG = true   ---オーラを出すためのフラグ
            self.timer = 0
            self:showMDTimer(unit, self.BUFF_BOX_LIST[1].ID)  ---マギアドライブタイマー表示
            self:execAddBuff(unit, self.BUFF_BOX_LIST[1])
            self:execAddBuff(unit, self.ABILITY_BOX_LIST[1])
            self:execAddBuff(unit, self.ABILITY_BOX_LIST[2])
            self:execAddBuff(unit, self.ABILITY_BOX_LIST[3])
        else
            ---MD中の超奥義：チーム全体バフ
            self:teamAddBuff(self.SKILL_BUFF_BOX_LIST[1])
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
    self.aura:setPosition(targetx, targety);
    self.aura:getSkeleton():setPosition(0, unit:getSkeleton():getPositionY())
    self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime, unit)
    if self.isAura then
        ---真奥義
        unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
    else
        ---マギアドライブ
        unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    end
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            ---MD終了処理
            self.isAura = false
            self.timer = 0
            self:setBuffBoxList()
            self:setSurface(unit, self.SURFACE_BOX_LIST[self.beforeMD])
            for id = 1084972001, 1084972003 do
                local condition = unit:getTeamUnitCondition():findConditionWithID(id)
                unit:getTeamUnitCondition():removeCondition(condition)
            end
            if self.aura ~= nil then
                self.aura:takeAnimation(0, "empty", true)   ---オーラ消去
            end
        else
            self.timer = self.timer + deltaTime
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "md2Start" then
        self:setAura(event.unit)
        self.aura:takeAnimation(0, "MD_loop", true); -- 【仮】
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0, "MD_in", true); -- 【仮】
        self.loopStart1FLG = false
        return
    end
    self.aura = unit:addOrbitSystemWithFile("MD_2", "MD_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0, "MD_in", true); -- 【仮】
    self:auraPosition(unit)
    self.loopStart1FLG = false
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:loopStart1(event.unit)   ---MDオーラ失敗時に動く
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:loopStart1(event.unit)
    return 1;
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)
    return 1;
end

---MDオーラ（移行モーション中にオーラ生成が漏れた場合の保険）
function class:loopStart1(unit)
    if self.loopStart1FLG then
        self:setAura(unit)
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:loopStart1(event.unit)
    self.skill5FLG = false
    if event.index == 5 then
        --超レオーネアビリティ対応
        self:checkPlusMdTime(event.unit);
        self.skill5FLG = true
        if not self.isAura then
            ---MD移行モーション
            event.unit:setNextAnimationName("skill5b")
            event.unit:setNextAnimationEffectName("empty") -- 【仮】
            self:setSurface(event.unit, self.SURFACE_BOX_LIST[self.beforeMD])
        else
            ---MD中の超奥義
            self:setSurface(event.unit, self.SURFACE_BOX_LIST[self.afterMD])
        end
    end
    return 1
end

function class:setSurface(unit, surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    --unit:setCutinVoice2(surfaceBox.VOICE);
    --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit, buffId)
    unit:createBattleStatusChangeTimeCount(3, 1, "battle_magia_d_time_gray.png", "battle_magia_d_time.png", 0, "unit/battle_trans_skill/frame_magiadrive.plist") -- 【仮】
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:checkPlusMdTime(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithType(172); -- 【仮】
    if cond ~= nil then
        self.AURA_INTERVAL = self.mdTime + cond:getValue();
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        for i = 1, 3 do
            self.ABILITY_BOX_LIST[i].DURATION = self.AURA_INTERVAL;
        end
    else
        self.AURA_INTERVAL = self.mdTime;
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        for i = 1, 3 do
            self.ABILITY_BOX_LIST[i].DURATION = self.AURA_INTERVAL;
        end
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit, buffBox)
    local buff = nil;
    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0, (conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
        end
        ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
        if targetCond ~= nil then
            if targetCond:getPriority() <= buffBox.PRIORITY then
                ---優先度が自身以下 → 削除して上書き
                unit:getTeamUnitCondition():removeCondition(targetCond)
            else
                ---優先度が自身より上 → 付与しない
                return
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON, buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE, buffBox.DURATION, buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:teamAddBuff(buffBox)
    local myTeam = self.gameUnit:getTeam()
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox)
        end
    end
end

function class:enemyAddBuff(unit, buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0, 6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox)
        end
    end
end

function class:buffRemover(unit, id)
    unit:getTeamUnitCondition():addCondition(id, 0, 0, 99999, 0)
end

class:publish();

return class;
