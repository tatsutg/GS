local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="バティスト", version=1.9, id=103216512});


function class:start(event)
    self.skillRate = 400
    self.addRate = 300

    self.BUFF_BOX_LIST = {
        ID = 1032165121,
        BUFF_ID = 17,      --与ダメ
        VALUE = 40,        --効果量
        DURATION = 999999,
        ICON = 214,
        COUNT = 1,
        MAX = 6
    }
    event.unit:setParameter("321_Blade","0")
    return 1
end

function class:run(event)
    if event.spineEvent == "addBlade" then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
    end
    return 1
end

function class:takeSkill(event)
    if event.index == 3 then
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST.ID);
        if buff ~= nil and buff:getValue() >= 40 * self.BUFF_BOX_LIST.MAX then
            event.unit:getBurstSkill2():setDamageRate(self.skillRate + self.addRate)
        else
            event.unit:getBurstSkill2():setDamageRate(self.skillRate)
        end
    end
    return 1
end

function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffBox.COUNT,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffBox.COUNT,buffBox.DURATION,buffBox.ICON);
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
    unit:setParameter("321_Blade",""..buffBox.COUNT)
    buffBox.COUNT = buffBox.COUNT < buffBox.MAX and buffBox.COUNT + 1 or buffBox.MAX
    megast.Battle:getInstance():updateConditionView();
end

class:publish();

return class;