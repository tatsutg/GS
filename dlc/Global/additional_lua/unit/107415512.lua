local class = summoner.Bootstrap.createUnitClass({label="サンタシオン", version=1.3, id=107415512});

--------[[バフ]]--------
function class:setBuffBoxList()
    self.SPECIAL3_BUFF = {
        ID = 1074165122,
        BUFF_ID = 17, -- ダメージ
        VALUE = 60,
        DURATION = 99999,
        ICON = 26,
        COUNT = 1,
        MAX = 4
    }
    self.SPECIAL3_BUFF2 = {
        ID = 1074165123,
        BUFF_ID = 13, -- 攻撃力
        VALUE = 60,
        DURATION = 99999,
        ICON = 3,
        COUNT = 1,
        MAX = 4
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    return 1
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "tree1" then
        local orbit = event.unit:addOrbitSystemWithFile("10741ef","tree1")
        orbit:setDamageRateOffset(1)
        orbit:setBreakRate(1)
    end
    if event.spineEvent == "daruma1" then
        local orbit = event.unit:addOrbitSystemWithFile("10741ef","daruma1")
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end

    if event.unit:getLevel() < 90  then
        return 1
    end

    -- if event.spineEvent == "special2Shion" then
    --     self:execAddBuff(event.unit,self.SPECIAL3_BUFF)
    --     self:execAddBuff(event.unit,self.SPECIAL3_BUFF2)
    -- end
    -- if event.spineEvent == "special3Shion" then
    --     self:execAddBuff(event.unit,self.SPECIAL3_BUFF)
    --     self:execAddBuff(event.unit,self.SPECIAL3_BUFF2)
    -- end

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
    if event.index == 3 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end
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

    buff:setMaxConditionIconNumber(buffBox.MAX);
    buff:setNumber(buffBox.COUNT);
    buffBox.COUNT = buffBox.COUNT < buffBox.MAX and buffBox.COUNT + 1 or buffBox.MAX
    buffBox.VALUE = 60 * buffBox.COUNT
    megast.Battle:getInstance():updateConditionView();

end



class:publish();

return class;