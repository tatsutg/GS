local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_星芯爆砕ゼファー", version=1.8, id=104137512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1041375101,  --奥義ダメージUP
            BUFF_ID = 17,
            VALUE = self.defaultBuffValue,
            DURATION = 30,
            ICON = 0
        },
        [2] = {
            ID = 1041375102,  --奥義ダメージUPアイコン用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 6
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill2Flg = false;
    self.skill2Count = 0;

    self.skill5Flg = false;
    self.defaultBuffValue = 200;
    self:setBuffBoxList()
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill2Flg then
        self.skill2Flg = false;
        self.skill2Count = self.skill2Count + 1;
        if self.skill2Count >= 6 then
            self.skill2Count = 6;
        end
        self.BUFF_BOX_LIST[1].VALUE = self.defaultBuffValue * self.skill2Count;
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2]);
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if buff ~= nil then
            buff:setNumber(self.skill2Count);
            buff:setThumbnailID(self.BUFF_BOX_LIST[2].ICON);
        end
        event.unit:setParameter("413_skillCount",self.skill2Count);
    end

    --奥義中か確認
    if self.skill5Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill5Flg = false;
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if buff ~= nil then
            if self.skill2Count == 0 then
                buff:setNumber(self.skill2Count);
                buff:setThumbnailID(0);
            else
                buff:setNumber(self.skill2Count);
                buff:setThumbnailID(self.BUFF_BOX_LIST[2].ICON);
            end
        end
        megast.Battle:getInstance():updateConditionView();
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill2Flg = true;
    elseif event.index == 3 then
        self.skill2Flg = false;
    elseif event.index == 5 then
        self.skill5Flg = true;
        if self.skill2Count >= 1 then
            self.BUFF_BOX_LIST[1].VALUE = self.defaultBuffValue * self.skill2Count;
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1]);
        end

        self.skill2Count = self.skill2Count - 2;
        if self.skill2Count <= 0 then
            self.skill2Count = 0;
        end
        event.unit:setParameter("413_skillCount",self.skill2Count);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
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