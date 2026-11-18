local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_ユーベル", version=1.8, id=108237312});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.orbitX = 0;
    self.orbitY = 0;
    self.sizeY = 0;
    self.orbit = nil;
    self.orbitTargetUnit = nil;
    self:setBuffBoxList();
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---オービット関連
    --停止系状態異常バフ監視
    if self:findBadStatus(event.unit) and self.orbit ~= nil then
        self:ringOff();
    end

    --奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.orbit ~= nil then
        self:ringOff();
    end

    if self.orbit ~= nil then
        local targetUnit = event.unit:getTargetUnit();
        self:setRingPosition(event.unit,targetUnit);
    end
    return 1
end

---状態異常監視
function class:findBadStatus(unit)
    local flg = false
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            flg = true
            break
        end
    end
    return flg
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
        event.unit:setDamageRateOffset(0.9)
        event.unit:setBreakRate(0.9)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "ringOn" then
        self:ringOff();
        self:setRing(event.unit,3);
    end

    if event.spineEvent == "ringOff" then
        self:ringOff();
    end
    return 1
end

-- 敵のサイズをチェックする。ユニットは1、大型ボスは3
function class:setRing(unit,size)
    self.orbitTargetUnit = unit:getTargetUnit();
    if self.orbitTargetUnit ~= nil and self.orbitTargetUnit:getSize() == size then
        self.sizeY = 200;
        self.orbit = unit:addOrbitSystem("energy_ring_large",0);
    else
        self.sizeY = 80;
        self.orbit = unit:addOrbitSystem("energy_ring_small",0);
    end

    self:setRingPosition(unit,self.orbitTargetUnit);
    self.orbit:setDamageRateOffset(0.1);
    self.orbit:setBreakRate(0.1);
end

function class:setRingPosition(unit,target)
    local targetUnit = unit:getTargetUnit();
    if self.orbitTargetUnit ~= target then
        self:ringOff();
        return 1;
    else
        targetUnit = self.orbitTargetUnit;
    end

    self.orbitX = targetUnit:getPositionX() + targetUnit:getSkeleton():getBoneWorldPositionX("root");
    self.orbitY = targetUnit:getPositionY() + targetUnit:getSkeleton():getBoneWorldPositionY("root") + self.sizeY;
    self.orbit:setPosition(self.orbitX, self.orbitY);
    self.orbit:setZOrder(targetUnit:getZOrder() + 10)
end

function class:ringOff()
    if self.orbit ~= nil then
        self.orbit:takeAnimation(0,"empty",false);
    end
    self.orbit = nil;
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

    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
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
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
    return buff
end


class:publish();

return class;