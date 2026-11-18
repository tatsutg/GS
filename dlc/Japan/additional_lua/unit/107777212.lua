local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒士郎", version=2.3, id=107777212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1077772121,
            BUFF_ID = 33,
            VALUE = 100,
            DURATION = 180,
            ICON = 0
        },
        [4] = {
            ID = 1077772124,---最終奥義フラグ
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [5] = {
            ID = 1077772125,
            BUFF_ID = 0,---背景変更直前FLG
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [6] = {
            ID = 1077772126,
            BUFF_ID = 21,---被ダメージ軽減
            VALUE = -30,
            DURATION = 1,
            ICON = 20
        },
        [7] = {
            ID = 1077772127,
            BUFF_ID = 27,---被ブレイク割合
            VALUE = -100,
            DURATION = 180,
            ICON = 0
        },
        [8] = {
            ID = 1077772128,
            BUFF_ID = 13, ---攻撃力
            VALUE = 200,
            DURATION = 35,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 200
        },
        [9] = {
            ID = 1077772129,
            BUFF_ID = 17, ---与ダメージ
            VALUE = 200,
            DURATION = 35,
            ICON = 26,
            GROUP_ID = 1029,
            PRIORITY = 200
        }
    }
end

---状態異常耐性---
function class:antiBadCondition(buffID,ID)
    local BUFF_LIST = {
        ID = ID,
        BUFF_ID = buffID,
        VALUE = 100,
        DURATION = 180,
        ICON = 0
    }
    local BUFF_LIST2 = {
        ID = ID + 1,
        BUFF_ID = buffID + 49,
        VALUE = 100,
        DURATION = 180,
        ICON = 0
    }
    self:execAddBuff(self.gameUnit,BUFF_LIST)
    self:execAddBuff(self.gameUnit,BUFF_LIST2)
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit

    self.skill5FLG = false
    self.superSkillFLG = false

    self.finalSkill = false
    self.timer = 0
    self.attackTime = 3
    self.num = 0
    self.BG_FLG = false

    self.preBGChangeFLG = false

    ---オービット
    self.orbitTime = 8
    self.count = self.orbitTime
    self.orbitDamage = 100
    self.skill5Damage = 1700

    if event.unit:getBurstSkill2() ~= nil then
        self:setDefaultBurstSkillRate2(event.unit)
    end
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

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---背景変更処理
    if self.skill5FLG then
        self.skill5FLG = false
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])---タイマー用バフ
        self:showTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---タイマー表示
        if event.unit:getLevel() >= 90 then
            ---アビリティのバフ
            self:antiBadCondition(54,107770)
            self:antiBadCondition(59,107772)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[7])
        end
    end

    ---背景変更前に怯んだ場合
    if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[5].ID) == nil and self.preBGChangeFLG then
        self.preBGChangeFLG = false
        BattleControl:get():changeBackgroundLWF(2035000,event.unit);
    end

    if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
        if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID) == nil then
            ---タイマー切れの場合(かつ超奥義中でない場合)
            self:BG_BGM_ChangeEnd(event.unit)
        end
        ---効果関係処理
        event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2)---真奥義ダメージ元に戻す
        event.unit:setCutinVoice3("VOICE_FULLARTS_CUTIN_C")
    else
        if event.unit:getLevel() >= 90 then
            if megast.Battle:getInstance():getBattleState() == kBattleState_active and event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[5].ID) == nil then
                ---オービット処理
                self.count = self.count - event.deltaTime
                if self.count < 0 then
                    self.count = self.count + self.orbitTime
                    self.sword = event.unit:addOrbitSystem("BG_attack")
                    self.sword:setActiveSkill(5)
                    self.sword:setDamageRateOffset(self.orbitDamage/self.skill5Damage)
                    self.sword:setBreakRate(0)
                end
            end
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[6])
            event.unit:setReduceHitStop(100,1)
        end
        ---効果関係処理
        event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate2 * 2)---真奥義ダメージ2倍
        event.unit:setCutinVoice3("VOICE_FULLARTS_CUTIN_C02")
    end

    ---攻撃超奥義時バフ付与
    if self.superSkillFLG then
        self.superSkillFLG = false
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[8])
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[9])
    end
    return 1
end

function class:BG_BGM_ChangeEnd(unit)
    BattleControl:get():restoreBackgroundLWF(unit);
    BattleControl:get():restoreBackgroundMusic(unit);
    ---オービットFLG
    self.count = self.orbitTime
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_xp_trans_equipment_time_gray_107777212.png","battle_xp_trans_equipment_time_107777212.png",0,"unit/battle_trans_skill/frame_107777212.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if event.spineEvent == "BGChange" and self.preBGChangeFLG then
        self.preBGChangeFLG = false
        BattleControl:get():changeBackgroundLWF(2035000,event.unit);
    end
    if event.spineEvent == "SK5" then
        event.unit:addOrbitSystem("SK5");
    end
    if event.spineEvent == "swordDelete" then
        self.sword = nil
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        if event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
            self.skill5FLG = true
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[5])
            buff:setRemoveOnResetState(true)
            self.preBGChangeFLG = true
            BattleControl:get():changeBackgroundMusic("GS602_EMIYA",event.unit);
        else
            event.unit:setNextAnimationName("skill5_2")
            event.unit:setNextAnimationEffectName("skill5_2")
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
            buff:setRemoveOnResetState(true)
            self.superSkillFLG = true
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if self.preBGChangeFLG then
        ---遷移後に背景変更
        self.preBGChangeFLG = false
        BattleControl:get():changeBackgroundLWF(2035000,event.unit);
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(83);
    if cond == nil then
        self:BG_BGM_ChangeEnd(event.unit)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    end
    return 1
end

function class:receive4(args)
    self:BG_BGM_ChangeEnd(self.gameUnit)
    return 1
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self:BG_BGM_ChangeEnd(event.unit)
    return 1
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