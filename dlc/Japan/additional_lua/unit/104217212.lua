local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒フィリル", version=2.6, id=104217212});


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
    self.gameUnit = event.unit;
    self:setBuffBoxList();

    self.auraLevel = 1;
    self.auraFollowFLG = false;
    self.aura = nil;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---オーラ除去
    if self.aura ~= nil then
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.aura:takeAnimation(0,"empty",false);
            self.aura = nil;
        end
    end
    ---オーラ位置
    self:auraPosition(event.unit);
    return 1;
end

---オーラ位置
function class:auraPosition(unit)
    if self.aura == nil then
        return;
    elseif self.auraLevel == 1 then
        self.auraFollowFLG = false;
        if self.aura ~= nil then
            self.aura = nil;
        end
        return;
    end

    local vec = unit:getisPlayer() and 1 or -1;
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPositionX(targetX);
    if self.auraFollowFLG then
        targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
        self.aura:setPosition(targetX,targetY);
        self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
    end
    self.aura:setZOrder(unit:getZOrder() + 1);
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 3 then
        if self:checkSize(event.unit,3) then
            event.unit:setNextAnimationName("skill3boss");
        end
    end
    return 1;
end

-- 敵のサイズをチェックする。ユニットは1、大型ボスは3
function class:checkSize(unit,size)
    local targetUnit = unit:getTargetUnit();
    if targetUnit ~= nil and targetUnit:getSize() == size then
        return true;
    end
    return false;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "regaliaAura1" then
        self.auraLevel = 1;
        self:setAura(event.unit,self.auraLevel);
    end

    if event.spineEvent == "regaliaAura2" then
        self.auraLevel = 2;
        self:setAura(event.unit,self.auraLevel);
    end

    if event.spineEvent == "loop2" then
        self.auraFollowFLG = true;
    end
    return 1;
end

---オーラ表示
function class:setAura(unit,level)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false);
        self.aura = nil;
    end

    self.aura = unit:addOrbitSystemWithFile("RegaliaAura_Butterfly","in"..level);
    self.aura:setOrbitType(4);
    self.aura:takeAnimation(0,"in"..level,true);
    if self.auraLevel == 2 then
        self.aura:setChainAnimationData(0,"loop"..level,"in"..level,true);
    elseif self.auraLevel == 1 then
        self.aura:setChainAnimationData(0,"empty","in"..level,true);
    end

    local vec = unit:getisPlayer() and 1 or -1;
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetX,targetY);
    self.auraFollowFLG = false;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false);
        self.aura = nil;
    end
    return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
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
        buffBox.FUNC(buff);
    end
    return buff;
end

function class:teamAddBuff(unit,buffBox)
    --自分PTからみて味方PTを取る
    local unitTeam = unit:getTeam();
    local targetTeam = nil
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end


class:publish();

return class;