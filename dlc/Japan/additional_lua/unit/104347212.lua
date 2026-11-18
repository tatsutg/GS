local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="鬼武者セティス", version=1.3, id=104347212});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "魔血開眼",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_C",
            SKILL_NAME = self.TEXT.AFTER_MD or "百鬼招来狂嵐無尽",   ---魔血開眼中は本来の超奥義名を出す
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---魔血開眼マーカー。タイマー表示の紐付けとデータ側 script_value_1 の契約IDを兼ねる
        [1] = {
            ID = 104347212,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        }
    }
    ---魔血開眼中の超奥義：45秒間、味方全体の与ダメージ150%UP（重複あり＝負IDで上書きせず重ねがけ）
    ---データ側の305（マーカー判定）だと移行モーション時に付与順の競合で誤付与するためLuaで付与する
    self.SKILL5_BUFF_BOX = {
        [1] = { ID = -1043472121, BUFF_ID = 17, VALUE = 150, DURATION = 45, ICON = 26 }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.isAura = false
    self.timer = 0
    self.AURA_BASE_INTERVAL = 120   ---魔血開眼の基本持続時間（超レオーネのマギアドライブ時間延長は対象外＝延長しない）
    self.AURA_INTERVAL = self.AURA_BASE_INTERVAL   ---現在の持続時間。真奥義で延長されるため基本値とは別に持つ
    self.MD_RECOVER_TIME = 40  ---真奥義で回復する魔血開眼の残り時間
    self:setSurfaceBoxList()
    self:setBuffBoxList()

    self.skill5FLG = false     ---超奥義発動フラグ
    self.skill3FLG = false     ---真奥義発動フラグ
    self.loopStart1FLG = false ---オーラ生成が漏れた場合の保険フラグ
    self.deadFLG = -1          ---自動蘇生、コンティニュー分岐用フラグ

    event.unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(), event.unit:getElementType());
    return 1
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
    self:skill3Control(event.unit)
    return 1
end

function class:skill5Control(unit)
    if self.skill5FLG then
        self.skill5FLG = false
        if not self.isAura then
            ---魔血開眼へ移行
            self.isAura = true
            self.loopStart1FLG = true   ---オーラを出すためのフラグ
            self.timer = 0
            self.AURA_INTERVAL = self.AURA_BASE_INTERVAL   ---前回の延長分を持ち越さない
            self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL
            self:showMDTimer(unit, self.BUFF_BOX_LIST[1].ID)
            self:execAddBuff(unit, self.BUFF_BOX_LIST[1])
        else
            ---魔血開眼中の超奥義：味方全体に与ダメージUP
            self:teamAddBuff(self.SKILL5_BUFF_BOX[1])
        end
    end
end

function class:skill3Control(unit)
    if self.skill3FLG then
        self.skill3FLG = false
        self:recoverMDTime(unit)
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
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
    else
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
    end
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            ---魔血開眼終了処理
            self.isAura = false
            self.timer = 0
            self.AURA_INTERVAL = self.AURA_BASE_INTERVAL
            self:setBuffBoxList()
            self:setSurface(unit, self.SURFACE_BOX_LIST[self.beforeMD])
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
    if event.spineEvent == "mdStart" then
        self:setAura(event.unit)
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0, "Kaigan_loop", true);
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0, "Kaigan_in", true);
        self.loopStart1FLG = false
        return
    end
    self.aura = unit:addOrbitSystemWithFile("BloodKaigan2", "Kaigan_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0, "Kaigan_in", true);
    self:auraPosition(unit)
    self.loopStart1FLG = false
end

---魔血開眼オーラ（移行モーション中にオーラ生成が漏れた場合の保険）
function class:loopStart1(unit)
    if self.loopStart1FLG then
        self:setAura(unit)
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:loopStart1(event.unit)
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

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:loopStart1(event.unit)
    self.skill5FLG = false
    self.skill3FLG = false
    if event.index == 5 then
        self.skill5FLG = true
        if not self.isAura then
            ---魔血開眼移行モーション（skill5 は既定のまま、EFのみ差し替え）
            event.unit:setNextAnimationEffectName("skill5kaigan")
            self:setSurface(event.unit, self.SURFACE_BOX_LIST[self.beforeMD])
        else
            ---魔血開眼中の超奥義（EFは既定の 2-skill5）
            event.unit:setNextAnimationName("skill5b")
            self:setSurface(event.unit, self.SURFACE_BOX_LIST[self.afterMD])
        end
    elseif event.index == 3 then
        ---超奥義の前段で拾われることがあるため、実行は update に回す
        self.skill3FLG = true
    end
    return 1
end

function class:setSurface(unit, surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
end

function class:showMDTimer(unit, buffId)
    unit:createBattleStatusChangeTimeCount(3, 1, "battle_maketsukaigan_time_gray.png", "battle_maketsukaigan_time.png", 0, "unit/battle_trans_skill/frame_kaigan.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

---真奥義：魔血開眼中は残り時間を回復する（上限は開眼の持続時間のまま）
function class:recoverMDTime(unit)
    if not self.isAura then
        return
    end
    ---残り時間＋40秒でマーカーを付け直す。基本の120秒を超えて延長してよい（重ねがけも加算）。
    ---タイマー表示はバフの残り時間と最大値の比なので、setTime だけだと最大値が伸びずゲージが振り切れる（setTimeMax は Lua 非公開）
    self.AURA_INTERVAL = math.max(0, self.AURA_INTERVAL - self.timer) + self.MD_RECOVER_TIME
    self.timer = 0
    self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL
    self:execAddBuff(unit, self.BUFF_BOX_LIST[1])
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

---味方全体へのバフ付与
function class:teamAddBuff(buffBox)
    local myTeam = self.gameUnit:getTeam()
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox)
        end
    end
end

class:publish();

return class;
