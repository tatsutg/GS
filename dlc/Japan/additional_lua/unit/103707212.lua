local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒ジェイ", version=1.3, id=103707212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1037072120 + self.gameUnit:getIndex(),
            BUFF_ID = 21,
            VALUE = -10,
            DURATION = 0.5,
            ICON = 20
        },
        [2] = {
            ID = 1037072120 + self.gameUnit:getIndex(),
            BUFF_ID = 32,
            VALUE = 60,
            DURATION = 0.5,
            ICON = 14
        }
    }
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getLevel() >= 100 then
        if event.unit:getIsLeader() then
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        else
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        end
    end
    return 1
end

function class:teamAddBuff(unit,buffBox)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_orbit" then
        local orbit = event.unit:addOrbitSystem("orbit",0)
        orbit:setDamageRateOffset(0.3)
        orbit:setBreakRate(0.3)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if event.index == 5 then
        event.unit:setDamageRateOffset(0.7)
        event.unit:setBreakRate(0.7)
    end

    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
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


class:publish();

return class;