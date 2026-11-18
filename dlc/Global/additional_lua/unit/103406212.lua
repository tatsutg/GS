local class = summoner.Bootstrap.createUnitClass({label="ヴァルティー", version=1.3, id=103406212});
function class:setBuffBox(value)
    local buffBox =  {
        ID = 1034062121,
        BUFF_ID = 17, -- 攻撃力
        VALUE = 50 * value,
        DURATION = 20,
        ICON = 31,
        SCRIPT = {
            SCRIPT_ID = 58
        },
        GROUP_ID = 1064,
        PRIORITY = 50 * value
    }
    return buffBox
end

function class:start(event)
    self:addChangeSP(event.unit,100,1)
    --self:setBuffBoxList()
    return 1
end

function class:addChangeSP(unit,limit,rate)
    if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then return end
    if unit:getTakeOverBurstPoint() == nil or unit:getLevel() < 90 then return end
    local sp = unit:getTakeOverBurstPoint()*rate > limit and limit or unit:getTakeOverBurstPoint()*rate
    unit:addSPNonPvpCorrection(sp)
end


function class:takeSkill(event)
    if event.index == 3 then
        local count = 0
        for i = 0,6 do
            local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
            if teamUnit ~= nil and teamUnit:getElementType() == kElementType_Aqua then
                count = count + 1
            end
        end
        for i = 0,6 do
            local teamUnit = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self:setBuffBox(count))
            end
        end
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
