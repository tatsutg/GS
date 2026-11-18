local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒サクヤ", version=2.0, id=103516312});

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
            SKILL_NAME = self.TEXT.AFTER_MD or "閃式奥義「火樹銀花」",
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
            ID = 103516312,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0,
            LEVEL = 70
        },
        ---防御力無視
        [2] = {
            ID = 1035163122,
            BUFF_ID = 80,
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 89,
            LEVEL = 70
        },
        ---防御力無視
        [3] = {
            ID = 1035163123,
            BUFF_ID = 10,
            VALUE = 5,
            DURATION = self.AURA_INTERVAL,
            ICON = 36,
            LEVEL = 70
        },
        ---神族・精霊族へのダメージアップ
        [4] = {
            ID = 1035065114,
            BUFF_ID = 17, ---与ダメージアップ
            VALUE = 200,
            DURATION = self.AURA_INTERVAL,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 273,
                VALUE1 = 3,
                VALUE2 = 7
            },
            LEVEL = 70
        },
        ---回避率アップ
        [5] = {
            ID = 1035163125,
            BUFF_ID = 31,
            VALUE = self.baseValue,
            DURATION = 10,
            ICON = 16,
            GROUP_ID = 1027,
            PRIORITY = self.baseValue,
            COUNT = 0
        },
        ---物理ダメージアップ
        [6] = {
            ID = 1035163126,
            BUFF_ID = 17,
            VALUE = 100,
            DURATION = 15,
            ICON = 28,
            GROUP_ID = 1066,
            PRIORITY = 100,
            SCRIPT = {
                SCRIPT_ID = 4
            }
        },
        ---物理ダメージアップ
        [7] = {
            ID = 1035163127,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 228,
            COUNT = 0
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

    self.baseValue = 5
    self:setBuffBoxList()

    self.skill2FLG = false
    self.vanishFLG = false
    self.emptyFLG = false
    self.explosionFLG = false

    self.kunaiNumber = 1
    self.kunaiMax = 6
    self.kunai = {}
    for i = 1,self.kunaiMax do
        self.kunai[i] = nil
    end

    if event.unit:getBurstSkill2() ~= nil then
        self:setDefaultBurstSkillRate2(event.unit)
    end

    self.inWave = true
    return 1
end

function class:setDefaultBurstSkillRate2(unit)
    if unit:getParameter("defaultDamageRate2") ~= "" then
        self.defaultDamageRate2 = unit:getParameter("defaultDamageRate2")
    else
        self.defaultDamageRate2 = unit:getBurstSkill2():getDamageRate()
        unit:setParameter("defaultDamageRate2",self.defaultDamageRate2)
    end
end

function class:startWave(event)
    self.inWave = true
    return 1
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self:findWeapon(event.unit,50275500) and self.kunaiMax == 6 then
        self.kunaiMax = 7
    end
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    if self.skill2FLG then
        self.skill2FLG = false
        self.BUFF_BOX_LIST[5].VALUE = self.baseValue * self:countKunai()
        self.BUFF_BOX_LIST[5].PRIORITY = self.baseValue * self:countKunai()
        self.BUFF_BOX_LIST[5].COUNT = self:countKunai()
        if self.BUFF_BOX_LIST[5].VALUE ~= 0 then
            self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
        end
    end
    self.BUFF_BOX_LIST[7].COUNT = self:countKunai()
    event.unit:setParameter("351_Kunai",self:countKunai())
    if self.BUFF_BOX_LIST[7].COUNT == 0 then
        self.BUFF_BOX_LIST[7].ICON = 0
    else
        self.BUFF_BOX_LIST[7].ICON = 228
    end
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[7])
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

    ---クナイ設置処理
    if event.spineEvent == "setKunai" then
        if self.inWave and self:isHost() then
            for i = 1,3 do
                self:setKunai(event.unit,self.kunaiNumber)
                megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.kunaiNumber);
                self.kunaiNumber = self.kunaiNumber + 1
                if self.kunaiNumber >= self.kunaiMax + 1 then
                    self.kunaiNumber = 1
                end
            end
        end
    end
    ---クナイ待機処理
    for i = 1,self.kunaiMax do
        if event.spineEvent == "kunaiLoop"..i then
            if self.kunai[i] ~= nil then
                self.kunai[i]:takeAnimation(0,"kunaiIdle"..i,false);
            end
        end
    end
    ---クナイ爆破処理
    if event.spineEvent == "explosion" then
        self.explosionFLG = false
        for i,v in pairs(self.kunai) do
            if self.kunai[i] ~= nil then
                self.kunai[i]:takeAnimation(0,"kunaiEnd"..i,false);
                self.kunai[i] = nil
            end
        end
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan3","Kaigan_in");
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
    self.aura = unit:addOrbitSystemWithFile("Kaigan3","Kaigan2_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:setKunai(unit,num)
    if self.kunai[num] ~= nil then
        self.kunai[num]:takeAnimation(0,"empty",false);
        self.kunai[num] = nil
    end
    self.kunai[num] = unit:addOrbitSystem("kunaiFall"..num,0);
    self.kunai[num]:takeAnimation(0,"kunaiFall"..num,false);
    local posX = unit:getPositionX()
    local posY = unit:getPositionY()
    if num == 7 then
        posX = posX -100
        posY = posY -10
    end
    self.kunai[num]:setPosition(posX,posY)
end

function class:receive1(args)
    self:setKunai(self.gameUnit,args.arg)
    return 1;
end

function class:countKunai()
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        for i = 1,self.kunaiMax do
            self.kunai[i] = nil
        end
    end
    local count = 0
    for i,v in pairs(self.kunai) do
        if self.kunai[i] ~= nil then
            count = count + 1
        end
    end
    return count
end

function class:countKunaiCutin()
    local count = 0
    for i,v in pairs(self.kunai) do
        if self.kunai[i] ~= nil then
            count = count + 1
        end
    end
    return count
end

function class:isHost()
    local bool = false
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true
    end
    return bool
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

function class:endWave(event)
    self.inWave = false
    self:removeKunai()
    return 1;
end

---MD1オーラ
function class:loopStart1(unit)
    if self.explosionFLG then
        self.explosionFLG = false
        self:removeKunai()
    end
    self.vanishFLG = false
    if self.loopStart1FLG then
        if self.shinMode then
            self:shinSetAura(unit)
        else
            self:setAura(unit)
        end
    end
end

function class:removeKunai()
    for i,v in pairs(self.kunai) do
        if self.kunai[i] ~= nil then
            self.kunai[i]:takeAnimation(0,"empty",false);
            self.kunai[i] = nil
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
                if myTeamUnit:getRaceType() == 3 then
                    FLG = true
                elseif myTeamUnit:getRaceType() == 7 then
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
            event.unit:setNextAnimationName("shin_skill2")
            event.unit:setNextAnimationEffectName("shin_skill2")
        end
        self.skill2FLG = true
    elseif event.index == 3 then
        self.skill2FLG = false
        if not self.isAura then
            self.isAura = true
            self.timer = 0
            self.isBeforeSkill = true
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
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
            else
                self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
                event.unit:setNextAnimationName("skill3")
                event.unit:setNextAnimationEffectName("empty")
                self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
            end
        else
            self.explosionFLG = true
            event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2 + (self:countKunaiCutin() * 100))---クナイ*100ダメージ追加
            if self.shinMode then
                event.unit:setNextAnimationName("shin_skill3b")
                event.unit:setNextAnimationEffectName("shin_skill3b")
            else
                event.unit:setNextAnimationName("skill3b")
                event.unit:setNextAnimationEffectName("skill3b")
            end
            self.vanishFLG = true
            self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])
            self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
        end
    end
    return 1
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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    for i,v in pairs(self.kunai) do
        if self.kunai[i] ~= nil then
            self.kunai[i]:takeAnimation(0,"empty",false);
            self.kunai[i] = nil
        end
    end
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

    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView();
    end
end

class:publish();

return class;