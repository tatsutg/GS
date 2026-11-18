local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ミーナス", version=2.0, id=104077112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 4471,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 232
        },
        [2] = {
            ID = 4473,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 233
        },
        [3] = {
            ID = 4474,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 234
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill2 = false
    self.skill3 = false
    self.skill5 = false
    self.skillFLG = false
    self.count = 0
    self:setBuffBoxList()
    self:iconUpdate(event.unit)
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:iconUpdate(event.unit)
    return 1;
end

function class:iconUpdate(unit)
    local count = 0
    count = self:getParamCount(unit,"407_WeaponType4")
    if count < 1 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
    else
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)
    end
    count = self:getParamCount(unit,"407_WeaponType3")
    if count < 2 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
    else
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
    end
    count = self:getParamCount(unit,"407_WeaponType1")
    if (count % 2) == 0 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    else
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

function class:getParamCount(unit,param)
    ---発動回数を取得
    local count = 0
    if unit:getParameter(param) ~= "" then
        count = tonumber(unit:getParameter(param))
    end
    return count
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