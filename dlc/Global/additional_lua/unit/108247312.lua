local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒オカルン", version=1.8, id=108247312});

function class:setBuffBoxList()
    self.abilityTime = 120
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 108247312,
            BUFF_ID = 21, --被ダメ軽減
            VALUE = -30,
            DURATION = self.abilityTime,
            ICON = 20,
            GROUP_ID = 3873,
            PRIORITY = 30
        },
        [2] = {
            ID = 108247312,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

function class:checkParametor(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList();
    --self.skill5Dmg = event.unit:getBurstSkill3():getDamageRate();
    self.skill5Dmg = event.unit:setActiveSkill(5):getDamageRate();
    if event.unit:getParameter("skill5Count") == "" then
        event.unit:setParameter("skill5Count","0");
    end

    --ターボババア
    if event.unit:getParameter("turboFlg") == "" then
        event.unit:setParameter("turboFlg","TRUE");
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("skill5Count") == "" then
        event.unit:setParameter("skill5Count","0");
    end

    if event.unit:getParameter("turboFlg") == "" then
        event.unit:setParameter("turboFlg","TRUE");
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    --ターボババア
    if event.unit:getParameter("turboFlg") == "TRUE" then
        if event.unit:getLevel() >= 120 then
            if BattleControl:get():getTime() < self.abilityTime then
                self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],true)
            else
                self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false)
                event.unit:setParameter("turboFlg","FALSE");
            end
        end
        --瀕死判定
        if summoner.Utility.getUnitHealthRate(event.unit) < 0.4 then
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false)
            event.unit:setParameter("turboFlg","FALSE");
        end
    end
    return 1
end

function class:teamAddBuff(unit,buffBox,flg)
    --自分PTからみて味方PTを取る
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    for i = 0,7 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            if flg then
                if cond == nil then
                    buffBox.DURATION = self.abilityTime - BattleControl:get():getTime()
                    local buff = self:execAddBuff(myTeamUnit,buffBox)
                    if buff ~= nil then
                        buff:setCaster(unit)
                    end
                end
            else
                if cond ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(buffBox.ID)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        if tonumber(event.unit:getParameter("skill5Count")) < 2 then
            local count = tostring(event.unit:getParameter("skill5Count") + 1);
            event.unit:setParameter("skill5Count",count);
            --event.unit:getBurstSkill3():setDamageRate(self.skill5Dmg * 2);
            event.unit:setActiveSkill(5):setDamageRate(self.skill5Dmg * 2);
        else
            --event.unit:getBurstSkill3():setDamageRate(self.skill5Dmg);
            event.unit:setActiveSkill(5):setDamageRate(self.skill5Dmg);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false);
    event.unit:setParameter("turboFlg","FALSE");
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