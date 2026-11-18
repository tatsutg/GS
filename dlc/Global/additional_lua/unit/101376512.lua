local class = summoner.Bootstrap.createUnitClass({label="ケオネス", version=1.9, id=101376512});

function class:start(event)
    self.orbit = nil
    self.target = nil
    self.check = false
    return 1
end

function class:startWave(event)
    if self.orbit ~= nil then
        self.orbit:takeAnimation(0,"empty",true);
    end
    return 1
end

function class:update(event)
    if self.orbit ~= nil then
        if self.target ~= nil then
            if self.target ~= self.target:getTeam():getTeamUnit(self.target:getIndex()) then
                self.target = nil
                self.orbit:takeAnimation(0,"empty",true);
                return 1
            end
        else
            self.orbit:takeAnimation(0,"empty",true);
            return 1
        end

        local vec = event.unit:getisPlayer() and 1 or -1
        local targetX = self.target:getPositionX() + self.target:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        local targetY = self.target:getPositionY() + self.target:getSkeleton():getBoneWorldPositionY("MAIN") - 50;
        self.orbit:setPosition(targetX,targetY);
        self.orbit:getSkeleton():setPosition(0, self.target:getSkeleton():getPositionY() - 10)
    end
    return 1
end

function class:run(event)
    if event.spineEvent == "skill3_HIT" then
        self.check = false
        self.orbit = nil
        self.orbit = event.unit:addOrbitSystemWithFile("10137ef","skill3_HIT")
        self.orbit:takeAnimation(0,"skill3_HIT",false);
        self.orbit:setDamageRateOffset(0.5)
        self.orbit:setBreakRate(0.5)
    end
    if event.spineEvent == "end" then
        self.orbit:takeAnimation(0,"empty",true);
        self.orbit:getSkeleton():setPosition(0,0);
    end
    return 1
end

function class:attackDamageValue(event)
    if self.check then
        self.target = event.enemy
    end
    return event.value
end

function class:takeAttack(event)
    self.check = false
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    self.check = false
    if  event.index == 3 then
        self.check = true
        self:execAddBuff(event.unit,self:createBuffBox(event.unit))
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end
    return 1
end

function class:createBuffBox(unit)
    local buffBox = {
        ID = 1013765121,
        BUFF_ID = 17, -- ダメージ
        VALUE = 0,
        DURATION = 10,
        ICON = 26,
        GROUP_ID = 1068,
        PRIORITY = 0,
        SCRIPT = {
            SCRIPT_ID = 22,
            VALUE1 = 0,
            VALUE2 = 0
        }
    }
    local condValue = unit:getTeamUnitCondition():findConditionValue(32)
    buffBox.VALUE = condValue
    buffBox.PRIORITY = condValue
    buffBox.ICON = condValue < 0 and 27 or 26
    return buffBox
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.VALUE == 0 then return end
    
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            elseif cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return
            elseif cond:getPriority() <= buffBox.PRIORITY then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
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

