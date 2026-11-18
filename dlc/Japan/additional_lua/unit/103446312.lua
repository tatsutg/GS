local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="樹ロゼッタ", version=1.3, id=103446312});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "マギアドライブ",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "スターダスト・ハレーション",
            SE = "SE_BATTLE_040_UNIT_CALL"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103446312,
            BUFF_ID = 0, ---MDアイコンのみ
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        },
        [2] = {
            ID = 1034463121,
            BUFF_ID = 13, ---攻撃力アップ
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 3
        },
        [3] = {
            ID = 1034463122,
            BUFF_ID = 17, ---水属性に対するダメージアップ
            VALUE = 50,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 14,
                VALUE1 = 2
            }
        },
        [4] = {
            ID = 1034463122,
            BUFF_ID = 0, ---水属性に対するダメージアップを削除
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [5] = {
            ID = 103440000,
            BUFF_ID = 63, ---樹属性耐性ダウン
            VALUE = -30,
            DURATION = 15,
            ICON = 45,
            GROUP_ID = 2001,
            PRIORITY = 30
        },
        [6] = {
            ID = 20344701,
            BUFF_ID = 17, ---魔法ダメージアップ
            VALUE = 100,
            DURATION = 20,
            ICON = 29,
            SCRIPT = {
                SCRIPT_ID = 5
            },
            GROUP_ID = 1008,
            PRIORITY = 100
        },
        [7] = {
            ID = 20344702,
            BUFF_ID = 30, ---装備CT速度アップ
            VALUE = 50,
            DURATION = 20,
            ICON = 33,
            GROUP_ID = 1025,
            PRIORITY = 50
        },
        [8] = {
            ID = 103446312,
            BUFF_ID = 0, ---MD2アイコンのみ
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
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
    self.AURA_INTERVAL = 180---MD時間
    self:setSurfaceBoxList()

    self.MD2FLG = 0---MD2移行用フラグ(奥義で+1され2でMD2移行)
    self.isAura2 = false---MD2フラグ
    self.skill2FLG = false---skill2バフ用
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
    self:setDefaultBurstSkillRate(event.unit)
    self:setDefaultBurstSkillRate2(event.unit)
    event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()

    --超レオーネアビリティ対応
    self.mdTime = self.AURA_INTERVAL;
    return 1
end

function class:setDefaultBurstSkillRate(unit)
    if unit:getParameter("defaultDamageRate") ~= "" then
        self.defaultDamageRate = unit:getParameter("defaultDamageRate")
    else
        self.defaultDamageRate = unit:getBurstSkill():getDamageRate()
        unit:setParameter("defaultDamageRate",self.defaultDamageRate)
    end
end

function class:setDefaultBurstSkillRate2(unit)
    if unit:getParameter("defaultDamageRate2") ~= "" then
        self.defaultDamageRate2 = unit:getParameter("defaultDamageRate2")
    else
        self.defaultDamageRate2 = unit:getBurstSkill2():getDamageRate()
        unit:setParameter("defaultDamageRate2",self.defaultDamageRate2)
    end
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)

    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
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
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            ---MD1orMD2終了処理
            self.isAura = false
            self.timer = 0
            self:setBuffBoxList()
            self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
            unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
            self.MD2FLG = 0
            self.isAura2 = false
            self:execAddBuff(unit,self.BUFF_BOX_LIST[4])
            self.BUFF_BOX_LIST[5].VALUE = -30
            self.BUFF_BOX_LIST[5].PRIORITY = 30
            unit:getBurstSkill():setDamageRate(self.defaultDamageRate)---ダメージレート初期化
            unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2)---ダメージレート初期化
            if self.aura ~= nil then
                self.aura:takeAnimation(0,"empty",true)---オーラ消去
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
    if event.spineEvent == "md2Start" then
        ---MD2移行処理
        self:takeMD2(event.unit)
    end
    if event.spineEvent == "skill2" then
        self.skill2FLG = true
        if self.isAura then
            self.MD2FLG = self.MD2FLG + 1
        end
    end
    if event.spineEvent == "skill2MD2" then
        self.skill2FLG = true
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"MD_loop",true);
    end
    if event.spineEvent == "loopStart2" then
        self.aura:takeAnimation(0,"MD_loop2",true);
    end
    return 1
end

function class:setAura(unit)
    if self:findWeapon(unit,50270200) then
        unit:addSPWithPvpCorrection(50)
    end
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in",true);
        self.loopStart1FLG = false
        return
    end
    self.aura = unit:addOrbitSystemWithFile("MD_3","MD_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"MD_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false
end

function class:setAura2(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in2",true);
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.skill2FLG then
        if event.unit:checkLuaAddConditionList(self.BUFF_BOX_LIST[5].ID,event.enemy) then
            self:execAddBuff(event.enemy,self.BUFF_BOX_LIST[5])
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    self.skill2FLG = false
    return 1
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    self.skill2FLG = false
    return 1;
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    self.skill2FLG = false
    return 1;
end

---MD1オーラ
function class:loopStart1(unit)
    if self.loopStart1FLG then
        self:setAura(unit)
    end
end

---MD2効果+オーラ
function class:takeMD2(unit)
    if self.MD2FLG >= 1 and not self.isAura2 then
        ---MD2移行モーション
        self:showMDTimer2(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
        self.MD2FLG = 0
        self.isAura2 = true
        self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
        self.BUFF_BOX_LIST[5].VALUE = -70
        self.BUFF_BOX_LIST[5].PRIORITY = 70
        unit:getBurstSkill():setDamageRate(self.defaultDamageRate * 2)---ダメージレート2倍
        unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2 * 2)---ダメージレート2倍
        self:setAura2(unit)---MD2オーラ
    end
    return 1;
end

function class:showMDTimer2(unit,buffId)
    unit:resetBattleStatusChangeTimeCount()
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_a_time_gray.png","battle_magia_a_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
    megast.Battle:getInstance():updateConditionView()
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.skill2FLG = false
    if event.index == 2 then
        if self.isAura then
            if self.MD2FLG == 0 then
                ---奥義+MD2移行
                event.unit:setNextAnimationName("skill2MD2Begin")
                event.unit:setNextAnimationEffectName("2-skill2")
            end
            if self.isAura2 then
                ---MD2奥義
                event.unit:setNextAnimationName("skill2_MD2")
                event.unit:setNextAnimationEffectName("skill2_MD2")
            end
        end
    end
    if event.index == 3 then
        --超レオーネアビリティ対応
        self:checkPlusMdTime(event.unit);
        if not self.isAura then
            ---MD1移行モーション
            event.unit:setNextAnimationName("MD1begin")
            event.unit:setNextAnimationEffectName("empty")
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
            self.isAura = true
            self.loopStart1FLG = true---オーラを出すためのフラグ
            self.timer = 0
            self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
        else
            if self.isAura2 then
                ---MD2真奥義
                event.unit:setNextAnimationName("skill3_MD2")
                event.unit:setNextAnimationEffectName("skill3_MD2")
                self:teamAddBuff(self.BUFF_BOX_LIST[6])
                self:teamAddBuff(self.BUFF_BOX_LIST[7])
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
            else
                ---MD1真奥義
                event.unit:setNextAnimationName("skill3_MD1")
                event.unit:setNextAnimationEffectName("skill3_MD1")
                self:teamAddBuff(self.BUFF_BOX_LIST[6])
                self:teamAddBuff(self.BUFF_BOX_LIST[7])
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
            end
        end
    end
    return 1
end

function class:setSurface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    unit:setCutinVoice2(surfaceBox.VOICE);
    --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_d_time_gray.png","battle_magia_d_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:checkPlusMdTime(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithType(172);
    if cond ~= nil then
        self.AURA_INTERVAL = self.mdTime + cond:getValue();
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[2].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[8].DURATION = self.AURA_INTERVAL;
    else
        self.AURA_INTERVAL = self.mdTime;
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[2].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[8].DURATION = self.AURA_INTERVAL;
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
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
        end
        ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
        if targetCond ~= nil then
            if targetCond:getPriority() <= buffBox.PRIORITY then
                ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                unit:getTeamUnitCondition():removeCondition(targetCond)
            else
                ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                return
            end
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

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:teamAddBuff(buffBox)
    local myTeam = self.gameUnit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;
