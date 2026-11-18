local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="フリーレンコラボ_フェルン", version=1.8, id=108217212});
--class:inheritFromUnit("000");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1082101,
            BUFF_ID = 0,  --真奥義ダメージ倍率増加(iconのみ)
            VALUE = 0,
            DURATION = 999999,
            ICON = 31,
            COUNT = 0,
            MAX = 5
        },
    }
end

class.skill3PowerPoint = 700; -- 真奥義ダメージ率基礎値

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill3Flg = false
    self.skill3Cnt = 0
    self.skill3removeFlg = false
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

function class:endWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)

    if self.skill3Flg then
        self.skill3Flg = false
        self.skill3Cnt = self.skill3Cnt + 1
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        if self.skill3Cnt > 5 then
            self.skill3Cnt = 5
        elseif self.skill3Cnt <= 0 then
            self.skill3Cnt = 1
        end
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill3PowerPoint * self.skill3Cnt)
        end
    end

    if self.skill3removeFlg then
        self.skill3removeFlg = false
        self.skill3Cnt = 0
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(cond);
        end
    end

    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill3removeFlg = true
    elseif event.index == 3 then
        self.skill3Flg = true
        self.skill3removeFlg = false
    elseif event.index == 5 then
        self.skill3Flg = false
        self.skill3removeFlg = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill5BG" then
        event.unit:addOrbitSystem("skill5BG");
    end
    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    return 1
end


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
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