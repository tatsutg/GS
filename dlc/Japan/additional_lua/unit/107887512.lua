local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ペンシルゴン", version=1.3, id=107887512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [2] = {
            ID = 1078875122,
            BUFF_ID = 25,
            VALUE = 200,
            DURATION = 99999,
            ICON = 9,
            GROUP_ID = 3725,
            PRIORITY = 200
        },
        [3] = {
            ID = 1078875123,
            BUFF_ID = 17,
            VALUE = 350,
            DURATION = 99999,
            ICON = 26,
            GROUP_ID = 1029,
            PRIORITY = 350
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()

    self.beforeArts = 0
    self.skill2FLG = false
    self.skill3FLG = false
    self.skill5FLG = false
    self.bossBreakFLG = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill2FLG then
        ---奥義
        self.beforeArts = 2
        self.skill2FLG = false
    elseif self.skill3FLG then
        ---真奥義
        self.beforeArts = 3
        self.skill3FLG = false
    elseif self.skill5FLG then
        ---超奥義
        if self.beforeArts == 2 or self.beforeArts == 3 then
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[self.beforeArts])
            buff:setRemoveOnResetState(true);
        end
        self.skill5FLG = false
        self.beforeArts = 5
    end
    ---ボスブレイク時に物理装備回復
    if not self.bossBreakFLG and self:findBossBreak(event.unit) then
        for i = 0,6 do
            local myTeamUnit = event.unit:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:weaponCoolTimeReset(myTeamUnit)
            end
        end
        self.bossBreakFLG = true
    elseif self.bossBreakFLG and not self:findBossBreak(event.unit) then
        self.bossBreakFLG = false
    end
    return 1
end

function class:findBossBreak(unit)
    local bool = false
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
            if myTeamUnit:isBreak() then
                bool = true
            end
        end
    end
    return bool
end

function class:weaponCoolTimeReset(unit)
    local battleSkill = nil
    for i = 0,2 do
        battleSkill = unit:getItemSkill(i)
        if battleSkill ~= nil then
            if battleSkill:getBattleItem():getItemTypeAsInt() == 1 then
                battleSkill:setCoolTimer(0)
            end
        end
    end
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
    if event.index == 2 then
        ---奥義
        self.skill2FLG = true
    elseif event.index == 3 then
        ---真奥義
        self.skill2FLG = false
        self.skill3FLG = true
    elseif event.index == 5 then
        ---超奥義
        self.skill3FLG = false
        self.skill5FLG = true
    end
    return 1
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

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;