local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒マーレット", version=2.0, id=103837412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1038374121,
            BUFF_ID = 17,
            VALUE = 30,
            DURATION = 99999,
            ICON = 26,
            MAX = 10
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.itemUsed = {
        [0] = false,
        [1] = false,
        [2] = false,
    }
    return 1
end

---------------------------------------------------------------------------------
-- castItem
---------------------------------------------------------------------------------
function class:castItem(event)
    if event.item:getBattleItem():getItemTypeAsInt() == 1 then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    ---通常攻撃
    if event.spineEvent == "Explosion1" then
        local shot = event.unit:addOrbitSystem("SHOT",1)
        shot:setEndAnimationName("EXPLOSION1")
        shot:setDamageRateOffset(1/3)
        shot:setBreakRate(1/3)
    end
    if event.spineEvent == "Explosion2" then
        local shot = event.unit:addOrbitSystem("SHOT",1)
        shot:setEndAnimationName("EXPLOSION2")
        shot:setDamageRateOffset(1/3)
        shot:setBreakRate(1/3)
    end
    if event.spineEvent == "Explosion3" then
        local shot = event.unit:addOrbitSystem("SHOT",1)
        shot:setEndAnimationName("EXPLOSION3")
        shot:setDamageRateOffset(1/3)
        shot:setBreakRate(1/3)
    end
    ---スキル
    if event.spineEvent == "Explosion4" then
        local shot = event.unit:addOrbitSystem("SHOT",1)
        shot:setEndAnimationName("EXPLOSION4")
    end
    ---超奥義
    if event.spineEvent == "Explosion5" then
        local shot = event.unit:addOrbitSystem("SHOT",1)
        shot:setEndAnimationName("EXPLOSION5")
        shot:setDamageRateOffset(1/10)
        shot:setBreakRate(1/10)
    end
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
    if event.index == 5 then
        event.unit:setDamageRateOffset(9/10)
        event.unit:setBreakRate(9/10)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end
end

class:publish();

return class;