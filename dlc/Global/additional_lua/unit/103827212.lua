local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒超ロイ", version=2.0, id=103827212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        --[[
        [1] = {
            ID = 103827212,
            BUFF_ID = 96,
            VALUE = 100,
            DURATION = 10,
            ICON = 86,
            GROUP_ID = 0,
            PRIORITY = 100,
            WEIGHT = 100
        }
        ]]--
        [1] = {
            ID = 103827212,
            BUFF_ID = 21, ---物理ダメージ軽減
            VALUE = -50,
            DURATION = 30,
            ICON = 21,
            SCRIPT = {
                SCRIPT_ID = 4
            }
        },
        [2] = {
            ID = 103827212,
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
    self.gameUnit = event.unit
    self:setBuffBoxList()
    self.freezeFLG = false
    self.PB1FLG = false
    self.PB2FLG = false
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    return 1
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    if self:findTheProtagonist(event.unit) then
        event.unit:setBattleStartVoice("VOICE_BATTLESTART_B")
    end
    return 1
end

---レイアスサーチ
function class:findTheProtagonist(unit)
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
            if myTeamUnit:getBaseID() == 10101 then
                return true
            end
        end
    end
    return false
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if event.spineEvent == "Library_PB_Hit" then
        local orbit = event.unit:addOrbitSystem("PB_Hit",0)
        orbit:setDamageRateOffset(1/2);
        orbit:setBreakRate(1/2);
        self.freezeFLG = true
    end
    if event.spineEvent == "Library_PB_back" then
        local orbit = event.unit:addOrbitSystem("PB_back",0)
    end
    if event.spineEvent == "freezeEnd" then
        self.freezeFLG = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getIsLeader() and event.unit:getLevel() >= 100 then
        if BattleControl:get():getTime() < self.BUFF_BOX_LIST[1].DURATION then
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        else
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        end
    end
    if self.PB1FLG then
        self.PB1FLG = false
        for i = 0,6 do
            local myTeamUnit = event.unit:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:addSPWithPvpCorrection(200)
            end
        end
    elseif self.PB2FLG then
        self.PB2FLG = false
        for i = 0,6 do
            local myTeamUnit = event.unit:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX())
            end
        end
    end
    return 1
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
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.freezeFLG = false
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.freezeFLG = false
    if event.index == 7 then
        event.unit:setDamageRateOffset(1/2);
        event.unit:setBreakRate(1/2);
        if event.unit:getPhantomBulletCount() == 2 then
            self.PB1FLG = true
        elseif event.unit:getPhantomBulletCount() == 1 then
            self.PB2FLG = true
        end
    else
        event.unit:setDamageRateOffset(1);
        event.unit:setBreakRate(1);
    end
    return 1
end

--氷結付与ギミック(仕様から削除)
--[[
---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    if self.freezeFLG then
        --self:execAddBuff(event.enemy,self.BUFF_BOX_LIST[1])
    end
    return event.value
end
]]--

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil and buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupIDWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY,buffBox.WEIGHT);
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