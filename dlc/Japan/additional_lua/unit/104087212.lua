local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒超ロゼッタ", version=1.3, id=104087212});

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.skill = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "マギア・ドライブ",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_B_02",
            SKILL_NAME = self.TEXT.AFTER_MD or "マギア・アンリミテッド",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.skill] = {
            ACTIVE_SKILL = 5,
            VOICE = "VOICE_FULLARTS_CUTIN_C",
            SKILL_NAME = self.TEXT.SKILL or "天翔剣β-アルテミス",
            SE = "SE_BATTLE_040_UNIT_CALL"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10408700,
            BUFF_ID = 0, ---MDアイコンのみ
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        }
    }
    self.SKILL2_BUFF_BOX = {
        [1] = {
            ID = 10408701,
            BUFF_ID = 21,  --魔法耐性
            VALUE = 70,
            DURATION = 18,
            ICON = 175,
            GROUP_ID = 2056,
            PRIORITY = 70,
            SCRIPT = {
                SCRIPT_ID = 3
            }
        },
        [2] = {
            ID = 10408702,
            BUFF_ID = 21,  --魔法耐性
            VALUE = 170,
            DURATION = 18,
            ICON = 175,
            GROUP_ID = 2056,
            PRIORITY = 140,
            SCRIPT = {
                SCRIPT_ID = 3
            }
        }
    }
    self.SKILL5_BUFF_BOX = {
        [1] = {
            ID = 10408703,
            BUFF_ID = 17,  --魔法ダメージ
            VALUE = 120,
            DURATION = 9999999,
            ICON = 29,
            SCRIPT = {
                SCRIPT_ID = 286,
                VALUE1 = 3,
                VALUE2 = 2,
                VALUE3 = 1
            },
            GROUP_ID = 21013
        }
    }
    self.ABILITY_BOX_LIST = {
        [1] = {
            ID = 10408704,  --MD1効果
            BUFF_ID = 10, --SP自然増加
            VALUE = 7,
            DURATION = self.AURA_INTERVAL,
            ICON = 36
        },
        [2] = {
            ID = 10408705,  --MD2効果
            BUFF_ID = 22,  --クリティカル率
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 11
        },
        [3] = {
            ID = 10408706,  --MD2効果
            BUFF_ID = 17,  --クリティカルダメージ
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit

    self.isAura = false---MD1フラグ
    self.isAura2 = false---MD2フラグ
    self.mdFlg = false
    self.md2Flg = false
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
    self.timer = 0
    self.AURA_INTERVAL = 9999999---MD時間
    self:setSurfaceBoxList()

    self.MDAnimFlg = false
    self.skill2FLG = false
    self.skill3FLG = false
    self.skill5FLG = false
    self.skill3AddBP = 50
    self.skill5AddBP = 150
    self:setBuffBoxList()

    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1

    --self.weaponAddSP = 150
    --if event.unit:getParameter("weaponFlg") == "" then
    --    event.unit:setParameter("weaponFlg","true")
    --end

    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("weaponFlg") == "true" then
        event.unit:setParameter("weaponFlg","false")
        if self:findWeapon(event.unit,50315800) then
            event.unit:addSPWithPvpCorrection(self.weaponAddSP)
        end
    end
    return 1
end

function class:findWeapon(unit,weaponSkillId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponSkillId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -2
        self:deadMDCheck(event.unit)
    end

    if self.MDAnimFlg and event.unit:getUnitState() ~= kUnitState_skill then self.MDAnimFlg = false end
    if not self.MDAnimFlg then
        self:setMDCheck(event.unit)
    end

    self:setSkillBuff(event.unit)
    self:setSkill5Surface(event.unit)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    return 1
end

function class:deadMDCheck(unit)
    local hpRate = 100 * unit:getHP() / unit:getCalcHPMAX();
    if hpRate > 60 and self.isAura2 then
        self.md2Flg = true
    elseif hpRate > 30 and self.isAura2 then
        self.loopStart1FLG = true
    elseif hpRate > 30 and self.isAura then
        self.loopStart1FLG = true
    elseif hpRate <= 30 then
        self:resetMD(unit)
    end
end

function class:resetMD(unit)
    self.isAura = false
    self.isAura2 = false
    self:removeBuff(unit,self.BUFF_BOX_LIST[1].ID)
    self:removeBuff(unit,self.ABILITY_BOX_LIST[1].ID)
    self:removeBuff(unit,self.ABILITY_BOX_LIST[2].ID)
    self:removeBuff(unit,self.ABILITY_BOX_LIST[3].ID)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",true)---オーラ消去
    end
end

function class:setSkillBuff(unit)
    if self.skill2FLG then
        self.skill2FLG = false
        if self.isAura2 then
            self:enemyAddBuff(unit,self.SKILL2_BUFF_BOX[2])
        else
            self:enemyAddBuff(unit,self.SKILL2_BUFF_BOX[1])
        end
    elseif self.skill3FLG then
        self.skill3FLG = false
        if self.isAura or self.isAura2 then
            self:teamElementAddBP(unit,self.skill3AddBP)
        end
    elseif self.skill5FLG then
        self.skill5FLG = false
        if self.isAura2 then
            self:teamAddBuff(unit,self.SKILL5_BUFF_BOX[1])
            if megast.Battle:getInstance():isHost() then
                megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0)
            end
        end
    end
end

function class:setMDCheck(unit)
    local MDFlg = 0
    local hpRate = 100 * unit:getHP() / unit:getCalcHPMAX();
    if hpRate <= 60 and self.isAura2 then
        MDFlg = 1
    elseif hpRate <= 30 then
        MDFlg = 2
    end

    if MDFlg ~= 0 then
        if MDFlg == 1 then  --MD2削除、MD1移行
            self.isAura = true
            self.isAura2 = false
            self:showMDTimer(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
            self.aura:takeAnimation(0,"MD_loop",true);
            self:removeBuff(unit,self.ABILITY_BOX_LIST[2].ID)
            self:removeBuff(unit,self.ABILITY_BOX_LIST[3].ID)
        else  --MD,MD2削除
            self:resetMD(unit)
        end
    end
end

function class:removeBuff(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
end

function class:setSkill5Surface(unit)
    local hpRate = 100 * unit:getHP() / unit:getCalcHPMAX();
    if hpRate > 60 and self.isAura2 then
        --self:setSurface(unit,self.SURFACE_BOX_LIST[self.skill])
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.skill].VOICE)
    elseif hpRate >= 85 and not self.isAura2 then
        --self:setSurface(unit,self.SURFACE_BOX_LIST[self.afterMD])
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
    elseif hpRate < 85 then
        --self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
        unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
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
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            ---MD1orMD2終了処理
            self:resetMD(unit)
        end
    end
end

---------------------------------------------------------------------------------
-- receive5
---------------------------------------------------------------------------------
function class:receive5(args)
    self:teamAddBuff(self.gameUnit,self.SKILL5_BUFF_BOX[1])
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index == 5 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end

    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    self.skill2FLG = false
    self.skill3FLG = false
    self.skill5FLG = false
    if event.index == 2 then
        self.skill2FLG = true
    elseif event.index == 3 then
        self.skill2FLG = false
        self.skill3FLG = true
    elseif event.index == 5 then
        self.skill2FLG = false
        self.skill3FLG = false
        self.skill5FLG = true
        local hpRate = 100 * event.unit:getHP() / event.unit:getCalcHPMAX();
        if hpRate > 60 and self.isAura2 then
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.skill])
            event.unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.skill].VOICE)
        elseif hpRate >= 85 then
            event.unit:addSPWithPvpCorrection(self.skill5AddBP)
            ---MD2移行モーション
            self.isAura2 = false
            self.md2Flg = true
            self.MDAnimFlg = true
            event.unit:setNextAnimationName("MD_1")
            event.unit:setNextAnimationEffectName("empty")
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
            event.unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
        elseif hpRate < 85 then
            event.unit:addSPWithPvpCorrection(self.skill5AddBP)
            ---MD1移行モーション
            self.isAura = false
            self.loopStart1FLG = true
            self.MDAnimFlg = true
            event.unit:setNextAnimationName("MD_0")
            event.unit:setNextAnimationEffectName("empty")
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
            event.unit:setCutinVoice3(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
        end
    end
    return 1
end

function class:setSurface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
    --unit:setCutinVoice2(surfaceBox.VOICE);
    --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_d_time_gray.png","battle_magia_d_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:showMDTimer2(unit,buffId)
    unit:resetBattleStatusChangeTimeCount()
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_a_time_gray.png","battle_magia_a_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
    megast.Battle:getInstance():updateConditionView()
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill5_orbit" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit",0)
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end

    if event.spineEvent == "mdStart" then
        self:setAura(event.unit)
    end

    if event.spineEvent == "md2Start" then
        self:takeMD2(event.unit)
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
    if not self.isAura then
        ---MD1移行モーション
        self.isAura = true
        self.loopStart1FLG = true---オーラを出すためのフラグ
        self:showMDTimer(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
        self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
        self:execAddBuff(unit,self.ABILITY_BOX_LIST[1])
    end

    if self.deadFLG == -2 then
        self.deadFLG = -1
        self.loopStart1FLG = false
        self.aura:takeAnimation(0,"MD_loop",true);
        return
    end

    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in",true);
        self.loopStart1FLG = false
        return
    end

    self.aura = unit:addOrbitSystemWithFile("MD_2","MD_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"MD_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false
end

function class:setAura2(unit)
    if not self.isAura2 then
        ---MD2移行モーション
        self.isAura2 = true
        self.md2Flg = true---オーラを出すためのフラグ
        self:showMDTimer2(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
        self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
        self:execAddBuff(unit,self.ABILITY_BOX_LIST[1])
        self:execAddBuff(unit,self.ABILITY_BOX_LIST[2])
        self:execAddBuff(unit,self.ABILITY_BOX_LIST[3])
    end

    if self.deadFLG == -2 then
        self.deadFLG = -1
        self.md2Flg = false
        self.aura:takeAnimation(0,"MD_loop2",true);
        return
    end

    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in2",true);
        self.md2Flg = false
        return
    end

    self.aura = unit:addOrbitSystemWithFile("MD_2","MD_in2");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"MD_in2",true);
    self:auraPosition(unit)
    self.md2Flg = false
end

---MD1オーラ
function class:loopStart1(unit)
    if self.loopStart1FLG then
        self:setAura(unit)
    end
end

---MD2効果+オーラ
function class:takeMD2(unit)
    if self.md2Flg and not self.isAura2 then
        ---MD2移行モーション
        self:setAura2(unit)---MD2オーラ
        self:showMDTimer2(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
        --self:execAddBuff(unit,self.ABILITY_BOX_LIST[2])
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    return 1;
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    self:takeMD2(event.unit)---MD2効果+オーラ失敗時に動く
    return 1;
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
    return buff
end

function class:execAddBuff286(unit,buffBox)
    local countMax = buffBox.SCRIPT.VALUE1
    local buff  = nil;
    local count = 0
    local slotIndex = 40000
    local skill = self.gameUnit:getActiveBattleSkill();
    if skill ~= nil then
        slotIndex = slotIndex + (skill:getIndex() * 10000)
    end
    ---ユニットの位置
    local unitIndex = self.gameUnit:getIndex() * 1000000
    local min = (2861 + slotIndex + unitIndex) * -1
    local max = (2860 + countMax + slotIndex + unitIndex) * -1
    for i = min,max,-1 do
        ---フラグの個数だけカウント
        count = count + 1
        local buff = unit:getTeamUnitCondition():findConditionWithID(i);
        if buff == nil then
            ---フラグ付与
            unit:getTeamUnitCondition():addCondition(i,0,0,99999,0)
            break
        end
    end

    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.VALUE * count then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.VALUE * count then
            return;
        end
    end
    
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end
    ---番号など
    buff:setMaxConditionIconNumber(countMax);
    buff:setNumber(count);
    buff:setGroupID(buffBox.GROUP_ID);
    local priority = buffBox.VALUE
    if priority < 0 then
        priority = priority * -1
    end
    buff:setPriority(priority * count)
    megast.Battle:getInstance():updateConditionView();

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff286(myTeamUnit,buffBox)
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

function class:teamElementAddBP(unit,BP)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == kElementType_Aqua then
                myTeamUnit:addSPWithPvpCorrection(BP)
            end
        end
    end
end


class:publish();

return class;