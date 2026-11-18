local class = summoner.Bootstrap.createUnitClass({label="シャロン", version=1.9, id=103155412});

function class:start(event)
    self.BUFF_BOX = {
        ID = -1,
        BUFF_ID = 17, -- ダメージ
        VALUE = 40,
        DURATION = 30,
        ICON = 217,
        SCRIPT =  {
            SCRIPT_ID = 5,
            VALUE1 = 10315 -- 確認用
        }
    }
    if self:findWeapon(event.unit,50261500) then
        self.BUFF_BOX.DURATION = 40
    end
    return 1
end

function class:update(event)
    local count = 0
    local conditionSize = event.unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then
    else
        for i = 0,(conditionSize - 1) do
            local cond = event.unit:getTeamUnitCondition():getAllConditionsAt(i);
            if cond ~= nil then
                if cond:getValue1() == 10315 then
                    count = count + 1
                end
            end
        end
    end
    if count > 20 then count = 20 end
    event.unit:setParameter("315_Applause",""..count)
    return 1;
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function class:run(event)
    if event.spineEvent == "skill2" then
        if self:findWeapon(event.unit,50261500) then
            self.BUFF_BOX.DURATION = 40
        end
        self:execAddBuff(event.unit,self.BUFF_BOX)
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