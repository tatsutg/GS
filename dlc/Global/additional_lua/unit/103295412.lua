local class = summoner.Bootstrap.createUnitClass({label="ミランダ", version=1.3, id=103295412});

class.BUFF_ID_LIST = {20329500,20329600,20329700}
class.ADD_VALUE = 50
class.RIVIVE_RATIO = 0.5
class.RINASCITA_BUFF = {
    ID = 1032964121,
    BUFF_ID = 0, -- 自然蘇生
    VALUE = 0,
    DURATION = 999999,
    ICON = 37
}
class.BARRIER_BUFF_2 = {
    ID = 1032964122,
    BUFF_ID = 98, -- 被ダメ無効
    VALUE = 8000,
    DURATION = 20,
    ICON = 24,
    EFFECT = 1,
    GROUP_ID = 1031,
    PRIORITY = 100
}
class.CHECK_BUFF_2 = {
    ID = 1032964124,
    BUFF_ID = 0, -- 確認用
    VALUE = 0,
    DURATION = 20,
    ICON = 0,
    GROUP_ID = 103296412,
    PRIORITY = 100
}

function class:start(event)
    self.gameUnit = event.unit
    return 1
end

function class:takeDamageValue(event)
    if event.value >= 1 then
        return self:checkBuff(event.unit,event.value)
    end
    return event.value
end

function class:checkBuff(unit,value)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.CHECK_BUFF_2.ID)
    local allBarrierValue = self:getAllBarrierBuff(unit)
    if buff ~= nil then
        if value >= allBarrierValue then
            self:removeBarrierBuff(unit)
            self:removeCondition(unit,self.CHECK_BUFF_2.ID)
            unit:addSPWithPvpCorrection(self.ADD_VALUE)
        end
    end
    return value
end

function class:getAllBarrierBuff(unit)
    local val = 0
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil and cond:getConditionTypeAsInt() == 98 then
            val = val + cond:getValue()
        end
    end

    return val
end

function class:removeBarrierBuff(unit)
    for _,id in pairs(self.BUFF_ID_LIST) do
        for i = 0,6 do
            local target = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil then
                self:removeCondition(target,id)
            end
        end
    end
end

function class:takeSkill(event)
    if event.index == 2 then
        self:execAddBuff(event.unit,self.BARRIER_BUFF_2);
        self:execAddBuff(event.unit,self.CHECK_BUFF_2)
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
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end
end

class:publish();

return class;