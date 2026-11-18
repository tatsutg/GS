local class = summoner.Bootstrap.createUnitClass({label="シモン", version=1.9, id=103305512});

function class:start(event)
    self.myIndex = event.unit:getIndex()
    self.BUFF_BOX = {
        ID = 1033051121,
        BUFF_ID = 17, -- ダメージ
        VALUE = 20,
        DURATION = 20,
        ICON = 26,
        COUNT = 1,
        MAX = 8
    }
    return 1
end
function class:takeSkill(event)
    if event.index == 2 then
        if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() or event.unit:getIndex() == self.myIndex then
            self:checkBuff(event.unit,self.BUFF_BOX)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX.ID);
    if buff ~= nil then
        local time = buff:getTime()
        event.unit:setParameter("330_ChainTime",""..math.ceil(time))
    else
        event.unit:setParameter("330_Chain",""..0)
        event.unit:setParameter("330_ChainTime",""..0)
    end
    return 1
end

function class:checkBuff(unit,buffBox)
    local buff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
    if buff ~= nil then
        buff:setTime(buffBox.DURATION)
        if buffBox.COUNT < buffBox.MAX then
            buffBox.COUNT = buffBox.COUNT < buffBox.MAX and buffBox.COUNT + 1 or buffBox.MAX
            unit:setParameter("330_Chain",""..buffBox.COUNT)
            buff:setValue(buffBox.COUNT * buffBox.VALUE)
            buff:setNumber(buffBox.COUNT)
            buff:setMaxConditionIconNumber(buffBox.MAX);
            megast.Battle:getInstance():updateConditionView();
        end
        return
    end
    buffBox.COUNT = 1
    unit:setParameter("330_Chain",""..buffBox.COUNT)
    self:execAddBuff(unit,buffBox)
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

    buff:setNumber(buffBox.COUNT);
    buff:setMaxConditionIconNumber(buffBox.MAX);
    megast.Battle:getInstance():updateConditionView();
end
class:publish();

return class;