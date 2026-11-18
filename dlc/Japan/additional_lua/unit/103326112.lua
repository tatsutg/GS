local class = summoner.Bootstrap.createUnitClass({label="プリシラ", version=1.3, id=103326112});

function class:setBuffBox(value)
    self.BUFF_BOX = {
        ID = 1033261121,
        BUFF_ID = 22, -- クリティカル
        VALUE = 100,
        DURATION = 20,
        ICON = 11,
        GROUP_ID = 1024,
        PRIORITY = 100
    }

    self.DMG_BUFF_BOX = {
        ID = 1033261122,
        BUFF_ID = 17, -- クリティカルダメージ
        VALUE = value,
        DURATION = 20,
        ICON = 26,
        SCRIPT = {
            SCRIPT_ID = 22
        },
        GROUP_ID = 1068,
        PRIORITY = value
    }
end

function class:start(event)
    self:addChangeSP(event.unit,100,1)

    return 1
end

function class:addChangeSP(unit,limit,rate)
    if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then return end

    if unit:getTakeOverBurstPoint() == nil or unit:getLevel() < 90 then return end

    local sp = unit:getTakeOverBurstPoint()*rate > limit and limit or unit:getTakeOverBurstPoint()*rate
    unit:addSP(sp)
end

function class:takeSkill(event)
    if event.index == 3 then
        local val = self:checkElement(event.unit)
        self:setBuffBox(val)
        ---【MEGA_D-9599】味方全体へのクリティカル率UPは、バフ無効化に当たるなら配らない（ダメージUPは配る）
        local critBlocked = isTeamConditionBlockedByLua ~= nil and isTeamConditionBlockedByLua(event.unit, self.BUFF_BOX.BUFF_ID, self.BUFF_BOX.ICON, false)
        for i = 0,6 do
            local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
            if teamUnit ~= nil then
                if not critBlocked then self:execAddBuff(teamUnit,self.BUFF_BOX) end
                if val > 0 then self:execAddBuff(teamUnit,self.DMG_BUFF_BOX) end
            end
        end
    end
    return 1
end

function class:checkElement(unit)
    local addValue = 0
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
        if teamUnit ~= nil and teamUnit:getElementType() == kElementType_Fire then
            addValue = addValue + 50
        end
    end
    return addValue
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