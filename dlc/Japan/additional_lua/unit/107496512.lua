local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒 道 蓮", version=1.3, id=107496512});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,
            VALUE = 50,
            DURATION = 15,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 50
        }

    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        local count = self:darkCount()
        self.BUFF_BOX_LIST[1].VALUE = 50 * count
        self.BUFF_BOX_LIST[1].PRIORITY = 50 * count
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    return 1
end

function class:darkCount()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(self.gameUnit:getisPlayer());
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == 5 then
                count = count + 1
            end
        end
    end
    return count
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
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView()
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
end

class:publish();

return class;