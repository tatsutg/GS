local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="光システィーナ", version=1.3, id=103466412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

----// start //----------------------------------------------------------------------------
function class:start(event)
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self.gameUnit = event.unit
    self.AURA_INTERVAL = event.unit:getTransEquipmentBaseTime()
    self:setBuffBoxList()
    self.WD_FLG = false
    self.WD_Delay = 5
    self.WD_Timer = 0
    self.isAura = false
    self.timer = 0
    --event.unit:setUseTransEquipmentExec(true)

    self.vanishFLG = false
    self.emptyFLG = false
    return 1
end


----// startWave //-----------------------------------------------------------------------------
function class:startWave(event)
    self.AURA_INTERVAL = event.unit:getTransEquipmentBaseTime()
    return 1
end

function class:setAura(unit)
    self.isAura = true
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"WD_loop",true);
        return
    end
    self.aura = unit:addOrbitSystemWithFile("WD_Holy","WD_loop");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"WD_loop",true);
    self:auraPosition(unit)
end

----// update //-----------------------------------------------------------------------------
function class:update(event)
    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
    end
    if self.WD_FLG then
        self.WD_Timer = self.WD_Timer + event.deltaTime
        self.WD_Timer = 0
        self.WD_FLG = false
        self:setAura(event.unit)
    end
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
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
        if not unit:getIsTransEquipmentNow() then
            self.isAura = false
            self.timer = 0
            --unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
            if self.aura ~= nil then
                self.aura:takeAnimation(0,"empty",true);
            end
        else
            if self.vanishFLG and not self.emptyFLG then
                self.aura:takeAnimation(0,"empty",true);
                self.emptyFLG = true
            elseif not self.vanishFLG and self.emptyFLG then
                self.emptyFLG = false
                self.aura:takeAnimation(0,"WD_loop",true);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self.vanishFLG = false
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 and event.unit:getIsTransEquipmentNow() then
        event.unit:setNextAnimationName("skill2_2")
        event.unit:setNextAnimationEffectName("2-skill2_2")
        self.vanishFLG = true
    elseif event.index == 3 then
        self.WD_FLG = true
        self.vanishFLG = true
    end
    return 1
end

----// dead //-----------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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
end

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;