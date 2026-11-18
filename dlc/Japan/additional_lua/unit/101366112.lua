local class = summoner.Bootstrap.createUnitClass({label="テリオドス", version=1.9, id=101366112});

function class:setBuffBox(value)
    self.BUFF_BOX = {
        ID = 1013661121,
        BUFF_ID = 13, -- 攻撃力
        VALUE = value * 50,
        DURATION = 50,
        ICON = 3,
        GROUP_ID = 1006,
        PRIORITY = value * 50
    }
    self.BUFF_BOX2 = {
        ID = -1,
        BUFF_ID = 17, -- ダメージ
        VALUE = 100,
        DURATION = 50,
        ICON = 26
    }
end

function class:start(event)
    self:setBuffBox(self:checkPartyRace(event.unit))
    return 1
end

function class:checkPartyRace(unit)
    local count = 0
    local team = megast.Battle:getInstance():getTeam(unit:getisPlayer())
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil and teamUnit:getRaceType() == 6 then
            count = count + 1
        end
    end
    return count
end

function class:takeSkill(event)
    if event.index == 3 then
        self:setBuffBox(self:checkPartyRace(event.unit))
        self:execAddBuff(event.unit,self.BUFF_BOX)
        self:execAddBuff(event.unit,self.BUFF_BOX2)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
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
end


class:publish();

return class;